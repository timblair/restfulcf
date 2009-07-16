<!--- -->
<fusedoc fuse="restfulcf/test/tests/core/RouteTest.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I test the route component
	</responsibilities>
</fusedoc>
--->

<cfcomponent extends="mxunit.framework.TestCase">

	<cffunction name="setup">
		<cfset args = {
			verb       = "GET",
			uri        = "/resources/:id",
			controller = "resources",
			method     = "index"
		}>
		<cfset route = createobject("component", "restfulcf.framework.core.Route").init(argumentcollection=args)>
	</cffunction>

	<cffunction name="uninitialised_route_should_have_invalid_verb">
		<cfset assertEquals("INVALID", createobject("component", "restfulcf.framework.core.Route").getVerb())>
	</cffunction>

	<cffunction name="route_should_return_correct_verb">
		<cfset assertEquals(args.verb, route.getVerb())>
	</cffunction>
	<cffunction name="route_should_return_correct_uri">
		<cfset assertEquals(args.uri, route.getURI())>
	</cffunction>
	<cffunction name="route_should_return_correct_controller_name">
		<cfset assertEquals(args.controller, route.getController())>
	</cffunction>
	<cffunction name="route_should_return_correct_method_name">
		<cfset assertEquals(args.method, route.getMethod())>
	</cffunction>

	<cffunction name="route_should_return_correct_verb_after_changing_verb">
		<cfset route.setVerb("POST")>
		<cfset assertEquals("POST", route.getVerb())>
	</cffunction>
	<cffunction name="route_should_return_correct_uri_after_changing_uri">
		<cfset route.setURI("/changes/:id")>
		<cfset assertEquals("/changes/:id", route.getURI())>
	</cffunction>
	<cffunction name="route_should_return_correct_controller_name_after_changing_controller">
		<cfset route.setController("changes")>
		<cfset assertEquals("changes", route.getController())>
	</cffunction>
	<cffunction name="route_should_return_correct_method_name_after_changing_method">
		<cfset route.setMethod("changed")>
		<cfset assertEquals("changed", route.getMethod())>
	</cffunction>

	<cffunction name="route_should_raise_exception_on_invalid_verb">
		<cftry>
			<cfset route.setVerb("INVALID")>
			<cfset fail("Setting invalid verb for route should have raised an exception")>
			<cfcatch type="coldfusion.tagext.validations.AttributeValueNotFromListException"></cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="route_should_match_for_valid_uri_path">
		<cfset assertTrue(route.matches(route.getVerb(), "/resources/1"))>
	</cffunction>
	<cffunction name="route_should_not_match_for_invalid_uri_path">
		<cfset assertFalse(route.matches(route.getVerb(), "/fail/test"))>
	</cffunction>
	<cffunction name="route_should_not_match_for_invalid_verb">
		<cfset assertFalse(route.matches("INVALID", "/resources/1"))>
	</cffunction>
	<cffunction name="complex_uri_route_should_match_for_valid_uri_path">
		<cfset route.setURI("/complex/:id/route/:part/:another")>
		<cfset assertTrue(route.matches(route.getVerb(), "/complex/1/route/2/3"))>
	</cffunction>
	<cffunction name="complex_uri_route_should_not_match_for_invalid_uri_path">
		<cfset route.setURI("/complex/:id/route/:part/:another")>
		<cfset assertFalse(route.matches(route.getVerb(), "/complex/1/route/2/3/fail"))>
	</cffunction>

	<cffunction name="route_should_return_correct_path_vars">
		<cfset var vars = route.getPathVars("/resources/1")>
		<cfset assertEquals(1, arraylen(structkeyarray(vars)), "Wrong number of path variables returned")>
		<cfset assertTrue(structkeyexists(vars, "id"), "Path var 'id' expected but not present")>
		<cfset assertEquals(1, vars['id'], "Path var 'id' has unexpected value")>
	</cffunction>
	<cffunction name="complex_uri_route_should_return_path_vars">
		<cfset var ret = "">
		<cfset var vars = "id|1,part|2,another|3">
		<cfset var bit = "">
		<cfset route.setURI("/complex/:id/route/:part/:another")>
		<cfset ret = route.getPathVars("/complex/1/route/2/3")>
		<cfset assertEquals(3, arraylen(structkeyarray(ret)), "Wrong number of path variables returned")>
		<cfloop list="#vars#" index="bit">
			<cfset assertTrue(structkeyexists(ret, listgetat(bit, 1, '|')), "Path var '#listgetat(bit, 1, '|')#' expected but not present")>
			<cfset assertEquals(listgetat(bit, 2, '|'), ret[listgetat(bit, 1, '|')], "Path var '#listgetat(bit, 1, '|')#' has unexpected value")>
		</cfloop>
	</cffunction>

</cfcomponent>
