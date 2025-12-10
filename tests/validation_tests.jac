walker validation_tests(){
    # Seed data and run basic validations
    u = seed_example_data();
    concepts = std.nodes(concept);
    lessons = std.nodes(lesson);
    users = std.nodes(user);
    if concepts.len() == 0 {
        print("FAIL: no concepts found");
        return false;
    }
    if lessons.len() < 1 {
        print("FAIL: no lessons found");
        return false;
    }
    if users.len() < 1 {
        print("FAIL: no users found");
        return false;
    }
    print("PASS: concepts=" + std.str(concepts.len()) + ", lessons=" + std.str(lessons.len()) + ", users=" + std.str(users.len()));
    return true;
}
