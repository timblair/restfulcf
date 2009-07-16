<!--- -->
<fusedoc fuse="restfulcf/test/tests/core/ResourceCountTest.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I test the resource count component
	</responsibilities>
</fusedoc>
--->

<cfcomponent extends="mxunit.framework.TestCase">

	<cffunction name="setup">
		<cfset counter = createobject("component", "restfulcf.framework.core.ResourceCount").init("resource_fixtures", 10)>
	</cffunction>

	<!--- basic counts --->
	<cffunction name="the_count_for_an_uninitalised_counter_should_be_zero">
		<cfset assertEquals(0, createobject("component", "restfulcf.framework.core.ResourceCount").getCount())>
	</cffunction>
	<cffunction name="the_count_for_an_initialised_counter_should_be_correct">
		<cfset assertEquals(10, counter.getCount())>
	</cffunction>
	<cffunction name="the_count_should_be_correct_after_being_set">
		<cfset counter.setCount(20)>
		<cfset assertEquals(20, counter.getCount())>
	</cffunction>

	<!--- increasing and decreasing --->
	<cffunction name="increasing_the_count_should_with_no_arguments_should_inc_by_1">
		<cfset counter.incCount()>
		<cfset assertEquals(11, counter.getCount())>
	</cffunction>
	<cffunction name="increasing_the_count_by_2_should_inc_by_2">
		<cfset counter.incCount(2)>
		<cfset assertEquals(12, counter.getCount())>
	</cffunction>
	<cffunction name="increasing_the_count_by_minus_1_should_dec_by_1">
		<cfset counter.incCount(-1)>
		<cfset assertEquals(9, counter.getCount())>
	</cffunction>
	<cffunction name="decreasing_the_count_should_with_no_arguments_should_dec_by_1">
		<cfset counter.decCount()>
		<cfset assertEquals(9, counter.getCount())>
	</cffunction>
	<cffunction name="decreasing_the_count_should_by_2_should_dec_by_2">
		<cfset counter.decCount(2)>
		<cfset assertEquals(8, counter.getCount())>
	</cffunction>
	<cffunction name="decreasing_the_count_by_minus_1_should_inc_by_1">
		<cfset counter.decCount(-1)>
		<cfset assertEquals(11, counter.getCount())>
	</cffunction>

	<!--- transforms --->
	<cffunction name="to_xml_should_return_a_valid_xml_packet">
		<cfset assertTrue(isxml(counter.toXML()))>
	</cffunction>
	<cffunction name="to_xml_should_return_a_root_node_with_the_correct_name">
		<cfset assertXpath("/resource_fixtures", xmlparse(counter.toXML()))>
	</cffunction>
	<cffunction name="to_xml_should_return_a_count_node">
		<cfset var xml = xmlparse(counter.toXML())>
		<cfset var nodes = xmlsearch(xml, "/resource_fixtures/count")>
		<cfset assertEquals(1, arraylen(nodes))>
		<cfset assertEquals(10, nodes[1].xmltext)>
	</cffunction>
	<cffunction name="to_html_should_return_a_string_containing_the_type_and_count">
		<cfset assertEquals("Number of resource fixtures = 10", counter.toHTML())>
	</cffunction>

</cfcomponent>
