module my_addrx::voting{
    use std::simple_map::{SimpleMap,Self};
    use std::vector;
    use std::signer;

    struct CandidateList has key{
        candidate_list: SimpleMap<address,u64>,
        c_list: vector<address>,
        winner: address
    }

    struct VoterList has key{
        voters: SimpleMap<address,u64>
    }

    public fun assert_is_owner(addr: address){
        assert!(addr == @my_addrx, 0);
    }

    public fun assert_uninitialized(addr: address){
        assert!(!exists<CandidateList>(addr), 1);
        assert!(!exists<VoterList>(addr), 1);
    }

    public fun assert_initialized(addr: address){
        assert!(exists<CandidateList>(addr), 2);
        assert!(exists<VoterList>(addr), 2);
    }

    public fun assert_not_contains_key(map: &SimpleMap<address,u64>, addr: &address){
        assert!(!simple_map::contains_key(map, addr), 3);
    }

    public fun assert_contains_key(map: &SimpleMap<address, u64>, addr: &address){
        assert!(simple_map::contains_key(map, addr), 4);
    }
    public entry fun initialize_with_candidate(account: &signer, c_addr: address) acquires CandidateList {
        let addr = signer::address_of(account);
        assert_is_owner(addr);
        assert_uninitialized(addr);
        let c_store = CandidateList{
            candidate_list: simple_map::create(),
            c_list: vector::empty<address>(),
            winner: @0x0
        };
        move_to(account, c_store);
        let v_store = VoterList{
            voters: simple_map::create(),
        };
        move_to(account, v_store);
        let c_store = borrow_global_mut<CandidateList>(addr);
        simple_map::add(&mut c_store.candidate_list, c_addr, 0);
        vector::push_back(&mut c_store.c_list, c_addr);
    }

    public entry fun add_candidate(account: &signer, c_addr: address) acquires CandidateList {
        let addr = signer::address_of(account);
        assert_is_owner(addr);
        assert_initialized(addr);
        let c_store = borrow_global_mut<CandidateList>(addr);
        assert!(c_store.winner == @0x0, 5);
        assert_not_contains_key(&c_store.candidate_list, &addr);
        simple_map::add(&mut c_store.candidate_list, c_addr, 0);
        vector::push_back(&mut c_store.c_list, c_addr);
    }

    public entry fun vote(account: &signer, c_addr: address, store_addr: address) acquires CandidateList, VoterList {
        let addr = signer::address_of(account);
        assert_initialized(store_addr);
        let c_store = borrow_global_mut<CandidateList>(store_addr);
        let v_store = borrow_global_mut<VoterList>(store_addr);
        assert!(c_store.winner == @0x0, 5);
        assert!(!simple_map::contains_key(&v_store.voters, &addr), 6);
        assert_contains_key(&c_store.candidate_list, &c_addr);
        let votes = simple_map::borrow_mut(&mut c_store.candidate_list, &c_addr);
        *votes = *votes + 1;
        simple_map::add(&mut v_store.voters, addr, 1);
    }

    public entry fun declare_winner(account: &signer) acquires CandidateList{
        let addr = signer::address_of(account);
        assert_is_owner(addr);
        assert_initialized(addr);
        let c_store = borrow_global_mut<CandidateList>(addr);
        assert!(c_store.winner == @0x0, 5);

        let candidates = vector::length(&c_store.c_list);
        let i = 0;
        let winner:address = @0x0;
        let max_votes: u64 = 0;
        while(i < candidates){
            let candidate = *vector::borrow(&c_store.c_list, (i as u64));
            let votes = simple_map::borrow(&c_store.candidate_list, &candidate);
            if(max_votes < *votes){
                max_votes = *votes;
                winner = candidate;
            };
            i = i + 1;
        };
        c_store.winner = winner;
    }
    #[test_only]
    use std::account;
    #[test(admin=@my_addrx)]
    public fun testing(admin:signer) acquires CandidateList, VoterList{
        let addr = signer::address_of(&admin);
        account::create_account_for_test(addr);
        initialize_with_candidate(&admin, @0x123);
        add_candidate(&admin, @0x456);
        let voter = account::create_account_for_test(@0x789);
        vote(&voter, @0x123, @my_addrx);
        declare_winner(&admin);
    }
}