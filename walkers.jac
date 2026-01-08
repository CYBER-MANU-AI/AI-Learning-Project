walker serve_lesson {
    has user_ref: any;
    has concept_id: str;
    has result: any = null;
}

walker seed_example_data {
                concept_node = c;
            // Walkers for AI Learning Project - Jac v0.8.8 compliant

            walker serve_lesson {
                // Walkers for AI Learning Project - Jac v0.8.8 compliant

                walker serve_lesson {
                    has user_ref: any;
                    has concept_id: str;
                    has result: any = null;

                    can serve with entry {
                        concept_node = null;
                        for (c in std.nodes(concept)) {
                            if c.concept_id == self.concept_id {
                                concept_node = c;
                            }
                        }
                        if concept_node == null {
                            print("Concept not found: " + self.concept_id);
                            return;
                        }

                        lessons = concept_node.neighbors(has_lesson);
                        completed = self.user_ref.neighbors(completed_lesson);
                        for (l in lessons) {
                            if l not in completed {
                                self.user_ref.current_node = l.lesson_id;
                                self.result = l;
                                return;
                            }
                        }
                        // nothing available
                        self.result = null;
                    }
                }

                walker generate_quiz {
                    has user_ref: any;
                    has quizzes: list = [];

                    can create with entry {
                        if self.user_ref.current_node == "" {
                            return;
                        }
                        current_lesson = null;
                        for (ll in std.nodes(lesson)) {
                            if ll.lesson_id == self.user_ref.current_node {
                                current_lesson = ll;
                            }
                        }
                        if current_lesson == null {
                            return;
                        }

                        current_concept = null;
                        for (cc in std.nodes(concept)) {
                            if cc.concept_id == current_lesson.concept_id {
                                current_concept = cc;
                            }
                        }

                        prerequisite_concepts = current_concept.neighbors(prerequisite);
                        prerequisite_lessons = [];
                        for (pc in prerequisite_concepts) {
                            for (pl in pc.neighbors(has_lesson)) {
                                prerequisite_lessons.append(pl);
                            }
                        }

                        all_lessons = [];
                        for (pl in prerequisite_lessons) {
                            all_lessons.append(pl);
                        }
                        all_lessons.append(current_lesson);

                        lesson_contents = [];
                        for (les in all_lessons) {
                            lesson_contents.append(les.content);
                        }
                        lesson_text = std.join(lesson_contents, "\n");

                        quiz_text = by llm("Create a short quiz based on the following lesson content:\n\n" + lesson_text);

                        new_quiz = spawn node(quiz) {
                            quiz_id = std.uuid();
                            lesson_id = current_lesson.lesson_id;
                            concept_id = current_concept.concept_id;
                            content = quiz_text;
                        };

                        current_lesson -[has_quiz]-> new_quiz;
                        current_concept -[has_quiz]-> new_quiz;
                        self.quizzes.append(new_quiz);
                        self.result = new_quiz;
                    }
                }

                walker take_quiz {
                    has user_ref: any;
                    has quiz_id: str;
                    has answers: list;
                    has result: dict = {};

                    can process with entry {
                        quiz_node = null;
                        for (q in std.nodes(quiz)) {
                            if q.quiz_id == self.quiz_id {
                                quiz_node = q;
                            }
                        }
                        if quiz_node == null {
                            print("Quiz not found: " + self.quiz_id);
                            self.result = {"score": 0, "feedback": "Quiz not found."};
                            return;
                        }

                        edge = self.user_ref -[took_quiz]-> quiz_node;
                        edge.answers = std.join(self.answers, ", ");

                        score = 0;
                        for (a in self.answers) {
                            if a == "correct" {
                                score += 1;
                            }
                        }
                        edge.score = score;

                        feedback = by llm("User answers:\n" + std.str(self.answers) + "\n\nQuiz content:\n" + quiz_node.content);
                        self.result = {"score": score, "feedback": feedback};
                    }
                }

                walker learn {
                    has user_ref: any;
                    has concept_id: str;
                    has completed: bool = false;

                    can execute with entry {
                        concept_node = null;
                        for (c in std.nodes(concept)) {
                            if c.concept_id == self.concept_id {
                                concept_node = c;
                            }
                        }
                        if concept_node == null {
                            print("Concept not found: " + self.concept_id);
                            return;
                        }

                        lessons = concept_node.neighbors(has_lesson);
                        completed_list = self.user_ref.neighbors(completed_lesson);

                        for (ls in lessons) {
                            if ls not in completed_list {
                                print("Starting lesson: " + ls.title);
                                self.user_ref.current_node = ls.lesson_id;

                                // ensure quiz exists
                                quiz_list = ls.neighbors(has_quiz);
                                if quiz_list.len() == 0 {
                                    g = root spawn generate_quiz(user_ref=self.user_ref);
                                }
                                // mark quiz answered and lesson completed for simple flow
                                ql = ls.neighbors(has_quiz);
                                if ql.len() > 0 {
                                    q = ql[0];
                                    self.user_ref -[answered_quiz]-> q;
                                }
                                self.user_ref -[completed_lesson]-> ls;
                                print("Completed lesson: " + ls.lesson_id);
                            }
                        }
                        print("All lessons completed for concept: " + self.concept_id);
                        self.completed = true;
                    }
                }

                walker seed_example_data {
                    has seeded_user: any = null;

                    can initialize with entry {
                        c = spawn node(concept) {
                            concept_id = "c_test";
                            title = "Test Concept";
                            description = "Concept for testing";
                        };

                        l1 = spawn node(lesson) {
                            lesson_id = "l_test_1";
                            title = "Test Lesson 1";
                            content = "Content for lesson 1.";
                            concept_id = c.concept_id;
                        };

                        l2 = spawn node(lesson) {
                            lesson_id = "l_test_2";
                            title = "Test Lesson 2";
                            content = "Content for lesson 2.";
                            concept_id = c.concept_id;
                        };

                        l3 = spawn node(lesson) {
                            lesson_id = "l_test_3";
                            title = "Test Lesson 3";
                            content = "Content for lesson 3.";
                            concept_id = c.concept_id;
                        };

                        c -[has_lesson]-> l1;
                        c -[has_lesson]-> l2;
                        c -[has_lesson]-> l3;

                        u = spawn node(user) {
                            username = "test_user";
                            mastery_map = {};
                            current_node = "";
                        };
                        self.seeded_user = u;
                        print("Seeded example data: concept " + c.concept_id + " with 3 lessons and user: " + u.username);
                    }
                }

                walker list_concepts {
                    has concept_list: list = [];

                    can list_all with entry {
                        self.concept_list = std.nodes(concept);
                        for (c in self.concept_list) {
                            print("Concept: " + c.concept_id + " - " + c.title);
                        }
                    }
                }

                walker list_lessons {
                    has concept_id: str;
                    has lesson_list: list = [];

                    can list_by_concept with entry {
                        c = null;
                        for (cc in std.nodes(concept)) {
                            if cc.concept_id == self.concept_id {
                                c = cc;
                            }
                        }
                        if c == null {
                            print("Concept not found: " + self.concept_id);
                            return;
                        }
                        self.lesson_list = c.neighbors(has_lesson);
                        for (l in self.lesson_list) {
                            print("Lesson: " + l.lesson_id + " - " + l.title);
                        }
                    }
                }

                walker view_user_progress {
                    has user_ref: any;
                    has progress: dict = {};

                    can show_progress with entry {
                        completed = self.user_ref.neighbors(completed_lesson);
                        taken = self.user_ref.neighbors(took_quiz);
                        print("User: " + self.user_ref.username);
                        print("Completed lessons:");
                        for (c in completed) {
                            print(" - " + c.lesson_id);
                        }
                        print("Taken quizzes:");
                        for (q in taken) {
                            print(" - Quiz: " + q.quiz_id);
                        }
                        self.progress = {"completed": completed, "taken": taken};
                    }
                }

                walker reset_user {
                    has user_ref: any;
                    has reset_done: bool = false;

                    can reset with entry {
                        self.user_ref.current_node = "";
                        self.user_ref.mastery_map = {};
                        print("Reset user: " + self.user_ref.username);
                        self.reset_done = true;
                    }
                }

                walker debug_graph {
                    has summary: dict = {};

                    can debug with entry {
                        print("Nodes summary (concepts and lessons):");
                        for (c in std.nodes(concept)) {
                            print("C: " + c.concept_id);
                        }
                        for (l in std.nodes(lesson)) {
                            print("L: " + l.lesson_id);
                        }
                        for (q in std.nodes(quiz)) {
                            print("Q: " + q.quiz_id);
                        }
                        self.summary = {
                            "concepts": std.nodes(concept).len(),
                            "lessons": std.nodes(lesson).len(),
                            "quizzes": std.nodes(quiz).len()
                        };
                    }
                }