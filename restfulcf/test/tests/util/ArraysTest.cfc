<!--- -->
<fusedoc fuse="restfulcf/test/tests/util/ArraysTest.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I test the array helper functions
	</responsibilities>
</fusedoc>
--->

<cfcomponent extends="mxunit.framework.TestCase">

	<cffunction name="setup">
		<cfset arrays = createObject("component", "restfulcf.framework.util.Arrays")>
	</cffunction>

	<!---
		Functions to test:
			join      - joins two arrays together
			split     - splits an array in to two parts
			slice     - returns a sub-set of a given array
			switch    - reverses an array
			merge     - merge two arrays of structures based on key value
			mergeSort - recursively merges and sorts an array of structures based on key value
	--->

	<!--- JOIN --->
	<cffunction name="join_of_two_empty_arrays_should_result_in_an_empty_array">
		<cfset var a = []>
		<cfset var b = []>
		<cfset var r = arrays.join(a, b)>
		<cfset assertEquals(0, arraylen(r))>
	</cffunction>
	<cffunction name="join_of_two_arrays_should_result_in_summed_array_length">
		<cfset var a = [1,2,3]>
		<cfset var b = [4,5]>
		<cfset var r = arrays.join(a, b)>
		<cfset assertEquals(arraylen(a) + arraylen(b), arraylen(r))>
	</cffunction>
	<cffunction name="join_of_two_arrays_should_order_resulting_array_a_then_b">
		<cfset var a = [1]>
		<cfset var b = [2]>
		<cfset var r = arrays.join(a, b)>
		<cfset assertEquals(1, r[1], "The first element of the joined array was not as expected")>
		<cfset assertEquals(2, r[2], "The second element of the joined array was not as expected")>
	</cffunction>

	<!--- SPLIT --->
	<cffunction name="split_should_return_an_array_containing_two_arrays">
		<cfset var a = []>
		<cfset var r = arrays.split(a, 1)>
		<cfset assertTrue(isArray(r), "Value returned from split was not an array")>
		<cfset assertEquals(2, arraylen(r), "Array returned from split did not have two elements")>
		<cfset assertTrue(isArray(r[1]), "First element returned from split was not an array")>
		<cfset assertTrue(isArray(r[2]), "Second element returned from split was not an array")>
	</cffunction>
	<cffunction name="split_of_empty_array_should_result_in_two_empty_arrays">
		<cfset var a = []>
		<cfset var r = arrays.split(a, 1)>
		<cfset assertEquals(0, arraylen(r[1]), "The first element of the joined array was not as expected")>
		<cfset assertEquals(0, arraylen(r[2]), "The second element of the joined array was not as expected")>
	</cffunction>
	<cffunction name="split_of_short_array_should_result_in_empty_second_array">
		<cfset var a = [1,2,3]>
		<cfset var r = arrays.split(a, 10)>
		<cfset assertEquals(3, arraylen(r[1]), "The first element of the joined array was not as expected")>
		<cfset assertEquals(0, arraylen(r[2]), "The second element of the joined array was not as expected")>
	</cffunction>
	<cffunction name="split_on_zero_should_result_in_empty_first_array">
		<cfset var a = [1,2,3]>
		<cfset var r = arrays.split(a, 0)>
		<cfset assertEquals(0, arraylen(r[1]), "The first element of the joined array was not as expected")>
		<cfset assertEquals(3, arraylen(r[2]), "The second element of the joined array was not as expected")>
	</cffunction>
	<cffunction name="result_of_split_should_have_correct_number_of_elements_in_total">
		<cfset var a = [1,2,3,4,5]>
		<cfset var r = arrays.split(a, 3)>
		<cfset assertEquals(arraylen(a), arraylen(r[1]) + arraylen(r[2]))>
	</cffunction>
	<cffunction name="result_of_split_should_have_correct_number_of_elements_in_each">
		<cfset var a = [1,2,3,4,5]>
		<cfset var r = arrays.split(a, 3)>
		<cfset assertEquals(3, arraylen(r[1]), "The first element of the joined array was not as expected")>
		<cfset assertEquals(2, arraylen(r[2]), "The second element of the joined array was not as expected")>
	</cffunction>
	<cffunction name="result_of_split_should_have_correct_ordering_of_elements">
		<cfset var a = [1,2,3,4,5]>
		<cfset var r = arrays.split(a, 3)>
		<cfset assertEquals(1, r[1][1], "The first element of the joined array was not as expected")>
		<cfset assertEquals(4, r[2][1], "The second element of the joined array was not as expected")>
	</cffunction>

	<!--- SLICE --->
	<cffunction name="slice_of_an_empty_array_should_return_an_empty_array">
		<cfset var a = []>
		<cfset var r = arrays.slice(a, 1, 1)>
		<cfset assertEquals(0, arraylen(r))>
	</cffunction>
	<cffunction name="slice_starting_past_the_end_should_return_an_empty_array">
		<cfset var a = [1,2,3]>
		<cfset var r = arrays.slice(a, 5, 1)>
		<cfset assertEquals(0, arraylen(r))>
	</cffunction>
	<cffunction name="slice_with_negative_offset_and_small_limit_should_return_an_empty_array">
		<cfset var a = [1,2,3]>
		<cfset var r = arrays.slice(a, -5, 1)>
		<cfset assertEquals(0, arraylen(r))>
	</cffunction>
	<cffunction name="slice_from_the_start_should_return_the_correct_number_of_results">
		<cfset var a = [1,2,3,4,5]>
		<cfset var r = arrays.slice(a, 1, 3)>
		<cfset assertEquals(3, arraylen(r))>
	</cffunction>
	<cffunction name="slice_from_the_middle_should_return_the_correct_number_of_results">
		<cfset var a = [1,2,3,4,5]>
		<cfset var r = arrays.slice(a, 2, 3)>
		<cfset assertEquals(3, arraylen(r))>
	</cffunction>
	<cffunction name="slice_from_the_end_should_return_the_correct_number_of_results">
		<cfset var a = [1,2,3,4,5]>
		<cfset var r = arrays.slice(a, 3, 3)>
		<cfset assertEquals(3, arraylen(r))>
	</cffunction>
	<cffunction name="slice_passing_end_of_array_should_only_return_to_the_end">
		<cfset var a = [1,2,3,4,5]>
		<cfset var r = arrays.slice(a, 3, 5)>
		<cfset assertEquals(3, arraylen(r))>
	</cffunction>
	<cffunction name="slice_with_a_zero_offset_should_return_one_less_than_the_limit">
		<cfset var a = [1,2,3,4,5]>
		<cfset var r = arrays.slice(a, 0, 5)>
		<cfset assertEquals(4, arraylen(r))>
	</cffunction>
	<cffunction name="slice_with_a_negative_offset_should_return_correct_number_of_results">
		<cfset var a = [1,2,3,4,5]>
		<cfset var r = arrays.slice(a, -2, 5)>
		<cfset assertEquals(2, arraylen(r))>
	</cffunction>

	<!--- SWITCH --->
	<cffunction name="switch_of_empty_array_should_return_empty_array">
		<cfset var a = []>
		<cfset var r = arrays.switch(a)>
		<cfset assertEquals(0, arraylen(r))>
	</cffunction>
	<cffunction name="switch_on_array_with_one_element_should_not_change">
		<cfset var a = [1]>
		<cfset var r = arrays.switch(a)>
		<cfset assertEquals(1, arraylen(r), "Resulting array length was different than expected")>
		<cfset assertEquals(1, r[1], "Resulting array value was different than expected")>
	</cffunction>
	<cffunction name="switch_on_array_with_two_elements_should_reverse_them">
		<cfset var a = [1,2]>
		<cfset var r = arrays.switch(a)>
		<cfset assertEquals(2, r[1], "First element in reversed array was different than expected")>
		<cfset assertEquals(1, r[2], "First element in reversed array was different than expected")>
	</cffunction>
	<cffunction name="switch_on_array_with_lots_of_elements_should_reverse_them">
		<cfset var a = [1,2,3,4,5,6,7,8,9]>
		<cfset var r = arrays.switch(a)>
		<cfset assertEquals(reverse(arraytolist(a)), arraytolist(r))>
	</cffunction>

	<!--- MERGE --->
	<cffunction name="merge_of_two_empty_arrays_return_an_empty_array">
		<cfset var a = []>
		<cfset var b = []>
		<cfset var r = arrays.merge(a, b, "x")>
		<cfset assertEquals(0, arraylen(r))>
	</cffunction>
	<cffunction name="merge_with_empty_second_array_should_just_return_first_array">
		<cfset var a = [ {id=1}, {id=3}, {id=5} ]>
		<cfset var b = []>
		<cfset var r = arrays.merge(a, b, "id")>
		<cfset assertEquals(3, arraylen(r), "Returned array has unexpected length")>
		<cfset assertEquals(1, r[1].id, "First element has unexpected ID")>
		<cfset assertEquals(5, r[3].id, "Last element has unexpected ID")>
	</cffunction>
	<cffunction name="merge_with_empty_first_array_should_just_return_second_array">
		<cfset var a = []>
		<cfset var b = [ {id=1}, {id=3}, {id=5} ]>
		<cfset var r = arrays.merge(a, b, "id")>
		<cfset assertEquals(3, arraylen(r), "Returned array has unexpected length")>
		<cfset assertEquals(1, r[1].id, "First element has unexpected ID")>
		<cfset assertEquals(5, r[3].id, "Last element has unexpected ID")>
	</cffunction>
	<cffunction name="merge_where_arrays_are_separate_should_not_shuffle_arrays_together">
		<cfset var a = [ {id=1}, {id=3}, {id=5} ]>
		<cfset var b = [ {id="a"}, {id="b"}, {id="c"} ]>
		<cfset var r = arrays.merge(a, b, "id")>
		<cfset assertEquals(6, arraylen(r), "Returned array has unexpected length")>
		<cfset assertEquals(1, r[1].id, "First element has unexpected ID")>
		<cfset assertEquals(5, r[3].id, "Last element has unexpected ID")>
		<cfset assertEquals("a", r[4].id, "Fourth element has unexpected ID")>
		<cfset assertEquals("c", r[6].id, "Sixth element has unexpected ID")>
	</cffunction>
	<cffunction name="merge_where_arrays_are_ordered_should_shuffle_arrays_together">
		<cfset var a = [ {id=1}, {id=3}, {id=5} ]>
		<cfset var b = [ {id=2}, {id=4}, {id=6} ]>
		<cfset var r = arrays.merge(a, b, "id")>
		<cfset var i = 0>
		<cfset assertEquals(6, arraylen(r), "Returned array has unexpected length")>
		<cfloop from="1" to="#arraylen(r)#" index="i">
			<cfset assertEquals(i, r[i].id, "Element #i# has unexpected ID")>
		</cfloop>
	</cffunction>
	<cffunction name="merge_of_component_arrays_should_work_with_properties_as_keys">
		<cfset var a = [ [], [] ]>
		<cfset var r = []>
		<cfset var i = 0>
		<cfloop from="1" to="6" index="i">
			<cfset arrayappend(a[(i MOD 2) + 1], createobject("component", "ArrayMergeFixture").init(i))>
		</cfloop>
		<cfset r = arrays.merge(a[2], a[1], "id")>
		<cfloop from="1" to="#arraylen(r)#" index="i">
			<cfset assertEquals(i, r[i].id, "Element #i# has unexpected ID")>
		</cfloop>
	</cffunction>
	<cffunction name="merge_of_component_arrays_should_work_with_function_as_keys">
		<cfset var a = [ [], [] ]>
		<cfset var r = []>
		<cfset var i = 0>
		<cfloop from="1" to="6" index="i">
			<cfset arrayappend(a[(i MOD 2) + 1], createobject("component", "ArrayMergeFixture").init(i))>
		</cfloop>
		<cfset r = arrays.merge(a[2], a[1], "getID")>
		<cfloop from="1" to="#arraylen(r)#" index="i">
			<cfset assertEquals(i, r[i].id, "Element #i# has unexpected ID")>
		</cfloop>
	</cffunction>

	<!--- MERGE SORT --->
	<cffunction name="merge_sort_on_simple_structure_should_sort_by_numeric_key">
		<cfset var a = [ {id=3}, {id=5}, {id=2}, {id=4}, {id=6}, {id=1} ]>
		<cfset var r = arrays.mergeSort(a, "id")>
		<cfloop from="1" to="#arraylen(r)#" index="i">
			<cfset assertEquals(i, r[i].id, "Element #i# has unexpected ID")>
		</cfloop>
	</cffunction>
	<cffunction name="merge_sort_on_simple_structure_should_sort_by_alpha_key">
		<cfset var a = [ {id="c"}, {id="e"}, {id="b"}, {id="d"}, {id="f"}, {id="a"} ]>
		<cfset var r = arrays.mergeSort(a, "id")>
		<cfloop from="1" to="#arraylen(r)#" index="i">
			<cfset assertEquals(chr(i + 96), r[i].id, "Element #i# has unexpected ID")>
		</cfloop>
	</cffunction>
	<cffunction name="merge_sort_on_component_arrays_should_sort_by_properties_as_keys">
		<cfset var a = []>
		<cfset var r = []>
		<cfloop list="3,5,2,4,6,1" index="i">
			<cfset arrayappend(a, createobject("component", "ArrayMergeFixture").init(i))>
		</cfloop>
		<cfset r = arrays.mergeSort(a, "id")>
		<cfloop from="1" to="#arraylen(r)#" index="i">
			<cfset assertEquals(i, r[i].id, "Element #i# has unexpected ID")>
		</cfloop>
	</cffunction>
	<cffunction name="merge_sort_on_component_arrays_should_sort_by_function_as_keys">
		<cfset var a = []>
		<cfset var r = []>
		<cfloop list="3,5,2,4,6,1" index="i">
			<cfset arrayappend(a, createobject("component", "ArrayMergeFixture").init(i))>
		</cfloop>
		<cfset r = arrays.mergeSort(a, "getID")>
		<cfloop from="1" to="#arraylen(r)#" index="i">
			<cfset assertEquals(i, r[i].id, "Element #i# has unexpected ID")>
		</cfloop>
	</cffunction>

</cfcomponent>
