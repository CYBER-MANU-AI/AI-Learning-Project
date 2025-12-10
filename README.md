# AI Learning Project - Adaptive Concept Learning System

## Project Overview

This is a concept-based adaptive learning platform built on Jaseci (Jac v0.8.8+). The system models learning as a graph of concepts, lessons, quizzes, and users. Quizzes are generated dynamically via the `by llm()` call so an LLM can produce question and feedback text based on lesson content.

## Architecture: Object-Spatial Programming (OSP)

### Nodes

- **user**: `username`, `mastery_map`, `current_node`
- **concept**: `concept_id`, `title`, `description`
- **lesson**: `lesson_id`, `title`, `content`, `concept_id`
- **quiz**: `quiz_id`, `lesson_id`, `concept_id`, `content`

### Edges

- **prerequisite**: concept → concept (prerequisite relationships)
- **has_lesson**: concept → lesson (lessons in a concept)
- **has_quiz**: concept/lesson → quiz (quizzes for lessons)
- **completed_lesson**: user → lesson (lessons completed)
- **took_quiz**: user → quiz (quiz attempts with `answers` and `score`)
- **answered_quiz**: user → quiz (quiz responses)

## AI Integration with byLLM

The walker `generate_quiz` gathers content from the current lesson and any prerequisite lessons, then calls `by llm()` to produce quiz text. The returned text becomes the `content` field of a spawned `quiz` node.

## Installation

```bash
pip install jaseci
```

See [Jaseci Documentation](https://docs.jaseci.org/) for detailed setup.

## Project Structure

```
├── schema.jac              # Node and edge definitions
├── walkers.jac             # Core walkers (serve_lesson, generate_quiz, take_quiz, learn)
├── README.md               # This file
├── examples/
│   └── demo_session.txt    # Example usage commands
├── scripts/
│   └── reset_graph.jac     # Graph reset helper walker
├── tests/
│   └── validation_tests.jac  # Validation walker
└── jac_api_endpoints.md    # REST API documentation
```

## Core Walkers

### serve_lesson
Returns the next available lesson for a user in a concept.

### generate_quiz
Generates a quiz for the current lesson using LLM.

### take_quiz
Processes user answers and generates feedback.

### learn
Orchestrates the full learning flow: serves lessons, generates quizzes, processes answers.

### Helper Walkers

- **seed_example_data**: Creates test data (concept, lessons, user)
- **list_concepts**: Lists all concepts
- **list_lessons**: Lists lessons for a concept
- **view_user_progress**: Shows user's learning progress
- **reset_user**: Clears user's progress
- **debug_graph**: Shows graph statistics

## Quick Start

### 1. Seed Example Data

```bash
jac run walkers.jac
```

Then in Jaseci:

```jac
root spawn seed_example_data();
```

### 2. List Concepts

```jac
root spawn list_concepts();
```

### 3. List Lessons

```jac
walker_inst = root spawn list_lessons(concept_id="c_test");
```

### 4. Run Learning Flow

```jac
user_node = std.find_node(user, .username == "test_user");
walker_inst = user_node spawn learn(user_ref=user_node, concept_id="c_test");
```

### 5. View Progress

```jac
user_node = std.find_node(user, .username == "test_user");
walker_inst = user_node spawn view_user_progress(user_ref=user_node);
```

## Expected Output

- `Seeded example data...` when running seed_example_data
- `Concept: c_test - Test Concept` from list_concepts
- `Lesson: l_test_1 - Test Lesson 1` from list_lessons
- Learning progress and quiz feedback from learn walker

## Extension & Customization

- Add fields to `mastery_map` in `user` node to track deeper metrics
- Implement web UI calling walkers via REST API
- Customize `by llm()` prompts in `generate_quiz` for different quiz styles
- Add prerequisite relationships between concepts

## Troubleshooting

- **LLM not configured**: `generate_quiz` will still run but may produce placeholder content
- **Syntax errors**: Ensure Jac v0.8.8 or later is installed
- **Walker spawn issues**: Use `root spawn walker_name()` for entry-point walkers

## Technology Stack

- **Language**: Jac (Jaseci)
- **Architecture**: Object-Spatial Programming (OSP)
- **AI**: byLLM (Claude Haiku or OpenAI models)
- **Graph**: Jaseci's native graph persistence

## Status

🚀 **Active Development** - Ongoing improvements and feature additions

## References

- [Jac Book - Nodes and Edges](https://docs.jaseci.org/jac_book/chapter_9/)
- [Jac Book - Walkers and Abilities](https://docs.jaseci.org/jac_book/chapter_10/)
- [byLLM Integration](https://docs.jaseci.org/learn/jac-byllm/)
