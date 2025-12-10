Project Overview
----------------
This is a concept-based adaptive learning platform built on Jaseci (Jac v0.8.8). The system models learning as a graph of concepts, lessons, quizzes, and users. Quizzes are generated dynamically via the `byllm()` call so an LLM can produce question and feedback text based on lesson content.

Graph Architecture
------------------
- Nodes:
  - `user` (fields: `username`, `mastery_map`, `current_node`)
  - `concept` (fields: `concept_id`, `title`, `description`)
  - `lesson` (fields: `lesson_id`, `title`, `content`, `concept_id`)
  - `quiz` (fields: `quiz_id`, `lesson_id`, `concept_id`, `content`)
- Edges:
  - `prerequisite` (between concepts)
  - `has_lesson` (concept -> lesson)
  - `has_quiz` (lesson/concept -> quiz)
  - `completed_lesson` (user -> lesson)
  - `took_quiz` (user -> quiz) with `answers` and `score`
  - `answered_quiz` (user -> quiz)

How AI Integration Works
------------------------
The walker `generate_quiz` gathers content from the current lesson and any prerequisite lessons, then calls `byllm()` to produce quiz text. The returned text becomes the `content` field of a spawned `quiz` node.

Installing Jac (v0.8.8)
------------------------
Refer to Jaseci documentation for installation. Example (local):

```bash
# using pip in a compatible environment
pip install jaseci==0.8.8
```

How to run schema + walkers
---------------------------
1. Start a Jaseci environment or have `jac` CLI available.
2. Load schema and walkers into Jaseci. Example CLI commands are in `examples/demo_session.txt`.

Seeding data
------------
Run the walker `seed_example_data()` to create a test concept, three lessons, and a test user.

Example CLI commands
--------------------
```bash
# seed data
jac run walkers.jac --run 'seed_example_data()'

# list concepts
jac run walkers.jac --run 'list_concepts()'

# list lessons for a concept
jac run walkers.jac --run 'list_lessons(concept_id="c_test")'

# run learn for the seeded user
jac run walkers.jac --run 'learn(std.find_node(user, .username == "test_user"), concept_id="c_test")'

# view user progress
jac run walkers.jac --run 'view_user_progress(std.find_node(user, .username == "test_user"))'
```

Expected sample outputs
-----------------------
- `Seeded example data...` from `seed_example_data()`
- `Concept: c_test - Test Concept` from `list_concepts()`
- `Lesson: l_test_1 - Test Lesson 1` etc. from `list_lessons()`
- `Quiz Score: 3` and feedback text from `learn()` (if simulation used)

How to extend the system
------------------------
- Add fields to `mastery_map` in `user` to track deeper metrics.
- Implement user-facing UI that calls the walkers via Jaseci REST API.
- Replace simulated answers in `learn()` with real user-submitted answers via `take_quiz()`.

Troubleshooting
---------------
- If `byllm()` is not configured, `generate_quiz` will still spawn `quiz` nodes but their content will be whatever `byllm()` returns in your environment. Ensure the provider is configured.
- If you see syntax errors, ensure you are running Jac v0.8.8 and not a different version.

Files
-----
- `schema.jac` - graph schema
- `walkers.jac` - core and helper walkers
- `examples/demo_session.txt` - demo commands
- `scripts/reset_graph.jac` - reset helpers
- `tests/validation_tests.jac` - basic validation walkers
