walker validation_tests {
    has passed: bool = false;

    can validate with entry {
        concepts = std.nodes(concept);
        lessons = std.nodes(lesson);
        users = std.nodes(user);
        if concepts.len() == 0 {
            print("FAIL: no concepts found");
            return;
        }
        if lessons.len() < 1 {
            print("FAIL: no lessons found");
            return;
        }
        if users.len() < 1 {
            print("FAIL: no users found");
            return;
        }
        print("PASS: concepts=" + std.str(concepts.len()) + ", lessons=" + std.str(lessons.len()) + ", users=" + std.str(users.len()));
        self.passed = true;
    }
}
