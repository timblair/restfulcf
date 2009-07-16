<!--- -->
<fusedoc fuse="restfulcf/test/tests/core/ResourceCollectionTest.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I test the resource collection component
	</responsibilities>
</fusedoc>
--->

<cfcomponent extends="mxunit.framework.TestCase">

	<cffunction name="setup">
		<cfset collection = createobject("component", "restfulcf.framework.core.ResourceCollection").init("resource_fixtures")>
		<cfset collection.add(createobject("component", "ResourceFixture").init(id=1))>
		<cfset collection.add(createobject("component", "ResourceFixture").init(id=2))>
		<cfset collection.add(createobject("component", "ResourceFixture").init(id=3))>
	</cffunction>

	<cffunction name="adding_an_invalid_resource_should_raise_exception">
		<cftry>
			<cfset collection.add("invalid")>
			<cfset fail("Adding an invalid resource should have raised an exception")>
			<cfcatch type="any"></cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getting_the_resources_should_return_an_array_of_resources">
		<cfset var resources = collection.getResources()>
		<cfset var i = 0>
		<cfset assertIsArray(resources, "Result is not an array")>
		<cfset assertEquals(3, arraylen(resources), "Resource array length was not as expected")>
		<cfloop from="1" to="3" index="i">
			<cfset assertEquals(i, resources[i].getID(), "Resource #i# has unexpected ID")>
		</cfloop>
	</cffunction>

	<cffunction name="getting_the_size_of_an_empty_collection_should_return_zero">
		<cfset assertEquals(0, createobject("component", "restfulcf.framework.core.ResourceCollection").size())>
	</cffunction>
	<cffunction name="getting_the_size_of_a_populated_collection_should_return_the_number_of_resources">
		<cfset assertEquals(3, collection.size())>
	</cffunction>
	<cffunction name="adding_a_resource_to_the_collection_should_increase_the_size">
		<cfset collection.add(createobject("component", "ResourceFixture").init(id=4))>
		<cfset assertEquals(4, collection.size())>
	</cffunction>

	<cffunction name="peeking_at_a_populated_collection_should_return_the_first_resource">
		<cfset assertEquals(1, collection.peek().getID())>
	</cffunction>
	<cffunction name="peeking_at_the_end_populated_collection_should_return_the_last_resource">
		<cfset assertEquals(3, collection.peek(collection.size()).getID())>
	</cffunction>
	<cffunction name="peeking_at_an_empty_collection_should_throw_an_exception">
		<cftry>
			<cfset createobject("component", "restfulcf.framework.core.ResourceCollection").peek()>
			<cfset fail("Exception wasn't raised")>
			<cfcatch type="coldfusion.runtime.InvalidArgumentException"></cfcatch>
		</cftry>
	</cffunction>
	<cffunction name="peeking_at_an_invalid_index_of_a_collection_should_throw_an_exception">
		<cftry>
			<cfset collection.peek(999)>
			<cfset fail("Exception wasn't raised")>
			<cfcatch type="coldfusion.runtime.InvalidArgumentException"></cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="sorting_a_collection_should_reorder_resources">
		<cfset var resources = []>
		<cfset var i = 0>
		<cfset collection.add(createobject("component", "ResourceFixture").init(id=0))>
		<cfset collection.sort("getID")>
		<cfset resources = collection.getResources()>
		<cfloop from="1" to="4" index="i">
			<cfset assertEquals(i-1, resources[i].getID(), "Resource #i# has unexpected ID")>
		</cfloop>
	</cffunction>
	<cffunction name="sorting_a_collection_in_descending_order_should_reorder_resources">
		<cfset var resources = []>
		<cfset var i = 0>
		<cfset collection.add(createobject("component", "ResourceFixture").init(id=0))>
		<cfset collection.sort("getID", "desc")>
		<cfset resources = collection.getResources()>
		<cfloop from="1" to="4" index="i">
			<cfset assertEquals((4-i), resources[i].getID(), "Resource #i# has unexpected ID")>
		</cfloop>
	</cffunction>

	<cffunction name="to_xml_should_return_a_valid_xml_packet">
		<cfset assertTrue(isxml(collection.toXML()))>
	</cffunction>
	<cffunction name="to_xml_should_return_a_root_node_of_type_array">
		<cfset assertXpath("/resource_fixtures[@type='array']", xmlparse(collection.toXML()))>
	</cffunction>
	<cffunction name="to_xml_should_return_a_node_for_each_resource">
		<cfset var xml = xmlparse(collection.toXML())>
		<cfset var nodes = xmlsearch(xml, "/resource_fixtures[@type='array']/resource_fixture")>
		<cfset assertEquals(3, arraylen(nodes))>
	</cffunction>
	<cffunction name="to_xml_on_empty_collection_should_return_an_empty_xml_packet">
		<cfset var empty = createobject("component", "restfulcf.framework.core.ResourceCollection").init("resource_fixtures")>
		<cfset var xml = xmlparse(empty.toXML())>
		<cfset var nodes = xmlsearch(xml, "/resource_fixtures[@type='array']/*")>
		<cfset assertEquals(0, arraylen(nodes))>
	</cffunction>

	<cffunction name="to_html_should_return_a_block_for_each_resource">
		<cfset var html = collection.toHTML()>
		<cfset var resources = html.split("<hr>")>
		<cfset assertEquals(3, arraylen(resources))>
	</cffunction>
	<cffunction name="to_html_on_empty_collection_should_return_an_empty_string">
		<cfset var empty = createobject("component", "restfulcf.framework.core.ResourceCollection").init("resource_fixtures")>
		<cfset assertEquals(0, len(empty.toHTML()))>
	</cffunction>

</cfcomponent>
