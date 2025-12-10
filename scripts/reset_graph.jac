walker reset_graph(){
    # This helper cannot safely delete nodes in all Jaseci deployments.
    # Use the Jaseci CLI or restart the Jaseci instance to reset persistent state.
    print("Reset helper: to fully reset the graph, restart Jaseci or clear the DB.");
    return true;
}
