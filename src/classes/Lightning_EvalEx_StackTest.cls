@isTest class Lightning_EvalEx_StackTest {

	@isTest static void testNewStackIsEmpty() {
		Lightning_EvalEx_Stack s = new Lightning_EvalEx_Stack();
		System.assert(s.empty());
		System.assertEquals(0, s.size());
	}

	@isTest static void testPushesToEmptyStack() {
		Lightning_EvalEx_Stack s = new Lightning_EvalEx_Stack();
		Integer numberOfPushes = 6;
		Object o;
		for (Integer i = 0; i < numberOfPushes; i++) {
			System.assertEquals(o = 'foo', s.push(o));
		}
		System.assertEquals(false, s.empty());
		System.assertEquals(numberOfPushes, s.size());
	}

	@isTest static void testPushThenPop() {
		Lightning_EvalEx_Stack s = new Lightning_EvalEx_Stack();
		Object o = 'foo';
		System.assertEquals(o, s.push(o));
		System.assertEquals(o, s.pop());
	}

	@isTest static void testPushThenPeek() {
		Lightning_EvalEx_Stack s = new Lightning_EvalEx_Stack();
		Object o = 'foo';
		System.assertEquals(o, s.push(o));
		Integer size = s.size();
		System.assertEquals(o, s.peek());
		System.assertEquals(size, s.size());
	}

	@isTest static void testPopToEmpty() {
		Lightning_EvalEx_Stack s = new Lightning_EvalEx_Stack();
		Integer numberOfPushes = (Integer)(Math.random() * 20 + 1);
		Object o;
		for (Integer i = 0; i < numberOfPushes; i++) {
			System.assertEquals(o = 'foo', s.push(o));
		}
		for (Integer i = 0; i < numberOfPushes; i++) {
			System.assertEquals('foo', s.pop());
		}
		System.assert(s.empty());
		System.assertEquals(0, s.size());
	}

	@isTest static void testPopEmptyStackThrows() {
		Lightning_EvalEx_Stack s = new Lightning_EvalEx_Stack();
		try {
			s.pop();
			System.assert(false);
		}
		catch (Lightning_EvalEx_Stack.EmptyStackException e) {}
	}

	@isTest static void testPeekEmptyStackThrows() {
		Lightning_EvalEx_Stack s = new Lightning_EvalEx_Stack();
		try {
			s.peek();
			System.assert(false);
		}
		catch (Lightning_EvalEx_Stack.EmptyStackException e) {}
	}

	@isTest static void testSearch() {
		Lightning_EvalEx_Stack s = new Lightning_EvalEx_Stack();
		s.push(null);
		s.push('foo');
		s.push('bar');
		s.push(null);
		s.push('foo');
		s.push('bar');
		System.assertEquals(6, s.size());
		System.assertEquals(1, s.search('bar'));
		System.assertEquals(2, s.search('foo'));
		System.assertEquals(3, s.search(null));
		System.assertEquals(-1, s.search('qux'));
	}
}