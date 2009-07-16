<!--- -->
<fusedoc fuse="restfulcf/test/tests/util/XMLTest.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I test the XML component functions to make sure they work
	</responsibilities>
</fusedoc>
--->

<cfcomponent extends="mxunit.framework.TestCase">

	<cffunction name="setup">
		<cfset short_xml_string = '<root attr="attr"><node1>node1</node1><node2><field1>field1</field1><field2>field2</field2><field3 attr="attr">field3a</field3><field3>field3b</field3></node2><node3 attr="attr">node3</node3></root>'>
		<cfset xml = createObject("component", "restfulcf.framework.util.XML")>
	</cffunction>

	<cffunction name="tostruct_should_return_a_structure_given_an_xml_string">
		<cfset assertTrue(isstruct(xml.toStruct(short_xml_string)))>
	</cffunction>
	<cffunction name="tostruct_should_return_a_structure_given_an_xml_node">
		<cfset assertTrue(isstruct(xml.toStruct(xmlparse(short_xml_string))))>
	</cffunction>

	<cffunction name="tostruct_should_return_node_attributes_by_default">
		<cfset var str = xml.toStruct(short_xml_string)>
		<cfset assertTrue(structkeyexists(str, "root::attributes") AND isstruct(str["root::attributes"]), "Root node has no attributes collection")>
		<cfset assertEquals(structcount(str["root::attributes"]), 1, "Root node has incorrect number of attributes")>
		<cfset assertTrue(structkeyexists(str.root, "node3::attributes") AND isstruct(str.root["node3::attributes"]), "Child node has no attributes collection")>
		<cfset assertEquals(structcount(str.root["node3::attributes"]), 1, "Child node has incorrect number of attributes")>
	</cffunction>
	<cffunction name="tostruct_should_not_return_node_attributes_when_told_not_to">
		<cfset var str = xml.toStruct(xml=short_xml_string, include_attr = FALSE)>
		<cfset assertFalse(structkeyexists(str, "root::attributes"), "Root node has attributes but shouldn't")>
	</cffunction>

	<cffunction name="tostruct_should_return_all_nodes_by_default">
		<cfset var str = xml.toStruct(xml=short_xml_string, include_root=FALSE)>
		<cfset assertTrue(structkeyexists(str, "node2") AND isstruct(str.node2), "Node should have children")>
		<cfset assertTrue(structkeyexists(str.node2, "field2") AND issimplevalue(str.node2.field2), "Child node should have a value")>
		<cfset assertEquals(str.node2.field2, "field2", "Child node value is incorrect")>
	</cffunction>
	<cffunction name="tostruct_should_only_return_nodes_to_a_given_depth">
		<cfset var str = xml.toStruct(xml=short_xml_string, depth=1, include_root=FALSE)>
		<cfset assertTrue(structkeyexists(str, "node2") AND issimplevalue(str.node2) AND NOT len(str.node2))>
	</cffunction>

	<cffunction name="tostruct_should_return_the_root_node_by_default">
		<cfset assertTrue(structkeyexists(xml.toStruct(xml=short_xml_string), "root"), "Root node doesn't exist")>
	</cffunction>
	<cffunction name="tostruct_should_not_return_the_root_node_when_told_not_to">
		<cfset var str = xml.toStruct(xml=short_xml_string, include_root=FALSE)>
		<cfset assertFalse(structkeyexists(str, "root"), "Root node exists but shouldn't")>
		<cfset assertTrue(structkeyexists(str, "node1"), "Child node should exist at root but doesn't")>
	</cffunction>

	<cffunction name="tostruct_should_return_array_for_multiple_nodes_with_same_name">
		<cfset var str = xml.toStruct(xml=short_xml_string, include_root=FALSE)>
		<cfset assertTrue(structkeyexists(str, "node2") AND structkeyexists(str.node2, "field3"), "Expected child node doesn't exist")>
		<cfset assertTrue(isarray(str.node2.field3), "Expected array of node values but not an array")>
		<cfset assertEquals(arraylen(str.node2.field3), 2, "Node array length not correct")>
		<cfset assertEquals(str.node2.field3[1], "field3a", "Node array item incorrect")>
	</cffunction>
	<cffunction name="tostruct_should_return_attributes_array_for_multiple_nodes_with_same_name">
		<cfset var str = xml.toStruct(xml=short_xml_string, include_root=FALSE)>
		<cfset assertTrue(structkeyexists(str, "node2") AND structkeyexists(str.node2, "field3::attributes"), "Expected attributes don't exist")>
		<cfset assertTrue(isarray(str.node2["field3::attributes"]), "Expected array of attributes but not an array")>
		<cfset assertEquals(arraylen(str.node2["field3::attributes"]), 2, "Attributes array length not correct")>
		<cfset assertTrue(isstruct(str.node2["field3::attributes"][1]), "Attributes for first node not a struct but should be")>
		<cfset assertTrue(structkeyexists(str.node2["field3::attributes"][1], "attr"), "Attribute not found")>
		<cfset assertEquals(str.node2["field3::attributes"][1].attr, "attr", "Attribute value incorrect")>
	</cffunction>

</cfcomponent>
