# Jaseci REST API Endpoints (example)

This file outlines recommended REST endpoints if you enable the Jaseci REST API, mapping to walkers in `walkers.jac`.

Enable the REST API
-------------------
Follow Jaseci docs to enable the REST API server. Typical steps:

- Configure `JASECI_REST` or start the `jaseci_server` with REST enabled.
- Ensure your environment has authentication configured if required.

Suggested endpoints
-------------------
- POST /api/learn
  - Body: { "username": "test_user", "concept_id": "c_test" }
  - Action: find `user` node by username and call `learn(user, concept_id)` walker

- POST /api/serve_lesson
  - Body: { "username": "test_user", "concept_id": "c_test" }
  - Action: call `serve_lesson` walker and return lesson node fields

- POST /api/take_quiz
  - Body: { "username": "test_user", "quiz_id": "<id>", "answers": ["a","b","c"] }
  - Action: call `take_quiz(user_node, quiz_id, answers)` and return score and feedback

- GET /api/list_concepts
  - Action: call `list_concepts()` and return array of concept objects

- GET /api/view_user_progress?username=test_user
  - Action: find user by username and call `view_user_progress(user)`

Notes
-----
- The REST wrapper should resolve `username` to a `user` node object and pass the node to the walkers using internal Jaseci APIs.
- Keep `byllm()` calls protected behind rate limits and authentication as appropriate for your provider.

Example server behavior (pseudo):
- POST /api/take_quiz receives body, resolves user node, calls `take_quiz.with(user=user, quiz_id=..., answers=...)`, returns JSON result.

Security
--------
- Validate incoming requests and authenticate clients before calling walkers that invoke LLMs to avoid misuse and unexpected costs.

