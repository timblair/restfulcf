<!--- -->
<fusedoc fuse="restfulcf/test/tests/core/ResourceTest.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I test the resource component
	</responsibilities>
</fusedoc>
--->

<cfcomponent extends="mxunit.framework.TestCase">

	<cffunction name="setup">
		<cfset base = createobject("component", "restfulcf.framework.core.Resource").init()>
		<cfset resource = createobject("component", "ResourceFixture").init()>
		<cfset params = {
			id            = 1,
			name          = "Default",
			email         = "test@test.com",
			created_at    = "{ts '1978-09-22 00:00:00'}",
			updated_at    = "{ts '1978-09-22 00:00:00'}",
			remote_id     = 2,
			numeric_id    = 3,
			decimal_id    = 3.45,
			string_id     = "x",
			numeric       = 0.2e3,
			integer       = 3,
			decimal       = 4.56,
			float         = 7.8,
			date_only     = "{d '1978-09-22'}",
			time_only     = "{t '12:34:56'}",
			date_and_time = "{ts '1978-09-22 12:34:56'}",
			boolean       = 1
		}>
		<cfset all_properties = listappend(lcase(structkeylist(params)), "location")>
	</cffunction>

	<cffunction name="base_init_should_return_instance_of_resource">
		<cfset assertIsTypeOf(base, "restfulcf.framework.core.Resource")>
	</cffunction>
	<cffunction name="extended_init_should_return_instance_of_resource">
		<cfset assertIsTypeOf(resource, "restfulcf.framework.core.Resource")>
	</cffunction>

	<!--- SETTERS AND GETTERS --->

	<cffunction name="get_on_base_should_raise_exception">
		<cftry>
			<cfset base.getInvalidProperty()>
			<cfset fail("get() on base component should have raised an exception")>
			<cfcatch type="Application"></cfcatch>
		</cftry>
	</cffunction>
	<cffunction name="set_on_base_should_raise_exception">
		<cftry>
			<cfset base.setInvalidProperty("x")>
			<cfset fail("set() on base component should have raised an exception")>
			<cfcatch type="Application"></cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="get_invalid_property_should_raise_exception">
		<cftry>
			<cfset resource.getInvalidProperty()>
			<cfset fail("get() on invalid property should have raised an exception")>
			<cfcatch type="Application"></cfcatch>
		</cftry>
	</cffunction>
	<cffunction name="set_invalid_property_should_raise_exception">
		<cftry>
			<cfset resource.setInvalidProperty("x")>
			<cfset fail("set() on invalid property should have raised an exception")>
			<cfcatch type="Application"></cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="get_valid_property_should_return_default_property_value">
		<cfset assertEquals(params['id'], resource.getID())>
		<cfset assertEquals(params['name'], resource.getName())>
		<cfset assertEquals(params['email'], resource.getEmail())>
	</cffunction>
	<cffunction name="set_valid_property_with_valid_value_should_succeed">
		<cftry>
			<cfset resource.setName("Test Name")>
			<cfcatch type="Application"><cfset fail(cfcatch.message)></cfcatch>
		</cftry>
		<cfset assertEquals("Test Name", resource.getName())>
	</cffunction>
	<cffunction name="set_valid_property_with_invalid_value_should_raise_exception">
		<cftry>
			<cfset resource.setID("x")>
			<cfset fail("set() on valid property with invalid data should have raised an exception")>
			<cfcatch type="Application"></cfcatch>
		</cftry>
		<cfset assertEquals(params['id'], resource.getID())>
	</cffunction>

	<cffunction name="get_property_with_no_default_value_before_set_should_raise_exception">
		<cftry>
			<cfset resource.getLocation()>
			<cfset fail("get() on valid property with no default should have raised an exception")>
			<cfcatch type="any"></cfcatch>
		</cftry>
	</cffunction>
	<cffunction name="get_property_with_no_default_value_after_set_should_succeed">
		<cftry>
			<cfset resource.setLocation("here")>
			<cfcatch type="any"><cfset fail(cfcatch.message)></cfcatch>
		</cftry>
		<cfset assertEquals("here", resource.getLocation())>
	</cffunction>

	<cffunction name="no_properties_should_be_available_via_accessors_on_base_resource">
		<cfset assertEquals(0, arraylen(structkeyarray(base.getProperties())))>
	</cffunction>
	<cffunction name="all_properties_should_be_available_via_accessors">
		<cfset var props = resource.getProperties()>
		<cfset var prop = "">
		<cfloop collection="#props#" item="prop">
			<cfif NOT listfind(all_properties, prop)><cfset fail("Found unexpected property: #prop#")></cfif>
		</cfloop>
		<cfloop list="#all_properties#" index="prop">
			<cfif NOT structkeyexists(props, prop)><cfset fail("Expected property not found: #prop#")></cfif>
		</cfloop>
	</cffunction>

	<cffunction name="setting_a_numeric_field_with_no_precision_should_not_coerce">
		<cfset resource.setNumeric(0.2e-3)>
		<cfset assertEquals(0.2e-3, resource.getNumeric())>
	</cffunction>
	<cffunction name="setting_an_int_should_coerce_value_if_non_integer">
		<cfset resource.setInteger(123.456)>
		<cfset assertEquals(123, resource.getInteger())>
	</cffunction>
	<cffunction name="setting_a_decimal_should_coerce_value_if_non_decimal">
		<cfset resource.setDecimal(123)>
		<cfset assertEquals("123.00", resource.getDecimal(), "trying to set a decimal with no decimal points")>
		<cfset resource.setDecimal(123.123)>
		<cfset assertEquals("123.12", resource.getDecimal(), "trying to set a decimal with too many decimal points")>
	</cffunction>
	<cffunction name="decimal_coercion_should_be_via_rounding">
		<cfset resource.setDecimal(1.234)>
		<cfset assertEquals("1.23", resource.getDecimal(), "should have rounded down")>
		<cfset resource.setDecimal(1.235)>
		<cfset assertEquals("1.24", resource.getDecimal(), "should have rounded up")>
	</cffunction>
	<cffunction name="setting_a_float_should_coerce_value_if_non_float">
		<cfset resource.setFloat(123)>
		<cfset assertEquals("123.0", resource.getFloat())>
		<cfset resource.setFloat(123.123)>
		<cfset assertEquals("123.123", resource.getFloat())>
	</cffunction>

	<cffunction name="setting_a_date_should_coerce_value_if_non_date">
		<cfset resource.setDate_Only("{ts '1978-09-22 12:34:56'}")>
		<cfset assertEquals("{d '1978-09-22'}", resource.getDate_Only())>
	</cffunction>
	<cffunction name="setting_a_time_should_coerce_value_if_non_time">
		<cfset resource.setTime_Only("{ts '1978-09-22 12:34:56'}")>
		<cfset assertEquals("{t '12:34:56'}", resource.getTime_Only())>
	</cffunction>
	<cffunction name="setting_a_datetime_should_coerce_value_if_non_datetime">
		<cfset resource.setDate_and_Time("1978-09-22 12:34:56")>
		<cfset assertEquals("{ts '1978-09-22 12:34:56'}", resource.getDate_and_Time())>
	</cffunction>

	<cffunction name="setting_a_boolean_should_coerce_to_numeric_form">
		<cfset resource.setBoolean(FALSE)>
		<cfset assertEquals(0, resource.getBoolean(), "trying to set a boolean to FALSE")>
		<cfset resource.setBoolean(TRUE)>
		<cfset assertEquals(1, resource.getBoolean(), "trying to set a boolean to TRUE")>
	</cffunction>

	<cffunction name="property_with_id_but_no_type_should_default_to_int_and_coerce">
		<cfset resource.setRemote_ID(12.345)>
		<cfset assertEquals(12, resource.getRemote_ID())>
	</cffunction>
	<cffunction name="property_with_id_and_numeric_type_should_default_to_int_and_coerce">
		<cfset resource.setNumeric_ID(12.345)>
		<cfset assertEquals(12, resource.getNumeric_ID())>
	</cffunction>
	<cffunction name="property_with_id_and_numeric_type_and_precision_should_coerce">
		<cfset resource.setDecimal_ID(1.234)>
		<cfset assertEquals(1.23, resource.getDecimal_ID())>
	</cffunction>
	<cffunction name="property_with_id_and_string_type_should_not_coerce">
		<cfset resource.setString_ID("qwerty")>
		<cfset assertEquals("qwerty", resource.getString_ID())>
	</cffunction>

	<!--- TRANSFORMATIONS --->

	<cffunction name="transform_to_xml_should_return_valid_xml">
		<cfset assertTrue(isxml(resource.toXML()))>
	</cffunction>
	<cffunction name="transform_to_xml_should_have_correctly_named_root_node">
		<cfset assertXpath("/resource_fixture", xmlparse(resource.toXML()))>
	</cffunction>
	<cffunction name="transform_to_xml_should_contain_all_properties_with_defaults">
		<cfset var xml = xmlparse(resource.toXML())>
		<cfset var param = "">
		<cfloop collection="#params#" item="param">
			<cfset assertXpath("/resource_fixture/#lcase(param)#", xml, params[param], "'#param#' property is missing or incorrect in generated XML")>
		</cfloop>
	</cffunction>
	<cffunction name="transform_to_xml_should_contain_all_properties_with_correct_types">
		<cfset var xml = xmlparse(resource.toXML())>
		<cfset var param = "">
		<cfloop collection="#params#" item="param">
			<cfset assertXpath("/resource_fixture/#lcase(param)#", xml, params[param], "'#param#' property is missing or incorrect in generated XML")>
		</cfloop>
	</cffunction>
	<cffunction name="transform_to_xml_should_set_correct_type_on_all_nodes">
		<cfset var xml = xmlparse(resource.toXML())>
		<cfset var props = resource.getProperties()>
		<cfset var type = "">
		<cfset var node = "">
		<cfset var param = "">
		<cfloop collection="#params#" item="param">
			<cfset node = xmlsearch(xml, '/resource_fixture/#lcase(param)#')>
			<cfif arraylen(node) NEQ 1>
				<cfset fail("Unexpected number of nodes returned for property #lcase(param)#: got #arraylen(node)#, expected 1")>
			</cfif>
			<cfset node = node[1]>
			<cfswitch expression="#props[param].type#">
				<cfcase value="numeric">
					<cfswitch expression="#props[param].precision#">
						<cfcase value="integer,decimal,float"><cfset type = props[param].precision></cfcase>
						<cfcase value="any"><cfset type = ""></cfcase>
						<cfdefaultcase><cfset fail("Invalid precision found for numeric property #lcase(param)#: #props[param].precision#")></cfdefaultcase>
					</cfswitch>
				</cfcase>
				<cfcase value="date">
					<cfswitch expression="#props[param].precision#">
						<cfcase value="date,time,datetime"><cfset type = props[param].precision></cfcase>
						<cfdefaultcase><cfset fail("Invalid precision found for date property #lcase(param)#: #props[param].precision#")></cfdefaultcase>
					</cfswitch>
				</cfcase>
				<cfcase value="boolean"><cfset type = "boolean"></cfcase>
				<cfdefaultcase><cfset type = ""></cfdefaultcase>
			</cfswitch>
			<cfif len(type)>
				<cfif NOT structkeyexists(node.xmlattributes, "type")>
					<cfset fail("No type found for property #lcase(param)#: expected #type#")>
				<cfelseif node.xmlattributes.type NEQ type>
					<cfset fail("Unexpected type found for property #lcase(param)#: found #node.xmlattributes.type# but expected #type#")>
				</cfif>
			<cfelse>
				<cfif structkeyexists(node.xmlattributes, "type")>
					<cfset fail("Found type for property #lcase(param)# when one was not expected: #node.xmlattributes.type#")>
				</cfif>
			</cfif>
			<cfset assertXpath("/resource_fixture/#lcase(param)#", xml, params[param], "'#param#' property is missing or incorrect in generated XML")>
		</cfloop>
	</cffunction>

	<cffunction name="transform_to_html_should_have_correctly_named_root_node">
		<cfset assertXpath("/dl[@class='resource_fixture']", xmlparse(resource.toHTML()))>
	</cffunction>
	<cffunction name="transform_to_html_should_contain_all_properties_with_defaults">
		<cfset var xml = resource.toHTML()>
		<cfset var term = xmlsearch(xml, "/dl/dt")>
		<cfset var data = xmlsearch(xml, "/dl/dd")>
		<cfset var i = 0>
		<cfset var f = 0>
		<cfloop from="1" to="#arraylen(term)#" index="i">
			<cfif NOT structkeyexists(params, term[i].xmltext)><cfset fail("Found unexpected node '#term[i].xmltext#'")></cfif>
			<cfset assertEquals(params[term[i].xmltext], data[i].xmltext, "Unexpected data for node '#term[i].xmltext#'")>
		</cfloop>
	</cffunction>

	<cffunction name="default_transform_to_csv_should_return_correct_data_with_header">
		<cfset var csv = resource.toCSV()>
		<cfset assertEquals(2, listlen(csv, chr(10)), "Returned CSV should have two lines")>
		<cfset assertEquals("boolean,created_at,date_and_time,date_only,decimal,decimal_id,email,float,id,integer,name,numeric,numeric_id,remote_id,string_id,time_only,updated_at", listgetat(csv, 1, chr(10)), "Header line is incorrect")>
		<cfset assertEquals("1,{ts '1978-09-22 00:00:00'},{ts '1978-09-22 12:34:56'},{d '1978-09-22'},4.56,3.45,test@test.com,7.8,1,3,Default,0.2e3,3,2,x,{t '12:34:56'},{ts '1978-09-22 00:00:00'}", listgetat(csv, 2, chr(10)), "Data line is incorrect")>
	</cffunction>
	<cffunction name="transform_to_csv_should_not_include_header_if_told_not_to">
		<cfset var csv = resource.toCSV(FALSE)>
		<cfset assertEquals(1, listlen(csv, chr(10)), "Returned CSV should have one line")>
		<cfset assertEquals("1,{ts '1978-09-22 00:00:00'},{ts '1978-09-22 12:34:56'},{d '1978-09-22'},4.56,3.45,test@test.com,7.8,1,3,Default,0.2e3,3,2,x,{t '12:34:56'},{ts '1978-09-22 00:00:00'}", csv, "Data line is incorrect")>
	</cffunction>
	<cffunction name="transform_to_csv_should_escape_commas_and_quotes">
		<cfset var csv = "">
		<cfset resource.setName('Billy "Bob" Brannigan')>
		<cfset resource.setEmail("Fake email, with a comma")>
		<cfset csv = resource.toCSV(FALSE)>
		<cfset assertEquals("1,{ts '1978-09-22 00:00:00'},{ts '1978-09-22 12:34:56'},{d '1978-09-22'},4.56,3.45,""Fake email, with a comma"",7.8,1,3,""Billy """"Bob"""" Brannigan"",0.2e3,3,2,x,{t '12:34:56'},{ts '1978-09-22 00:00:00'}", csv, "Data line is incorrect")>
	</cffunction>

</cfcomponent>
