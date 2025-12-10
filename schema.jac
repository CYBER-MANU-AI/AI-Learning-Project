
node user{
    has username: str;
    has mastery_map: dict;
    has current_node: str;
}

node concept{
    has concept_id: str;
    has title: str;
    has description: str;
}

node lesson{
    has lesson_id: str;
    has title: str;
    has content: str;
    has concept_id: str;
}

node quiz{
    has quiz_id: str;
    has lesson_id: str;
    has concept_id: str;
    has content: str;
}

edge prerequisite{
}

edge has_lesson{
}

edge has_quiz{
}

edge completed_lesson{
}

edge took_quiz{
    has answers: str;
    has score: int;
}

edge answered_quiz{
}