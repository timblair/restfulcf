<!--- -->
<fusedoc fuse="restfulcf/test/tests/core/cache/AbstractCacheTest.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I test the abstract (base) cache component
	</responsibilities>
</fusedoc>
--->

<cfcomponent extends="mxunit.framework.TestCase">

	<cffunction name="setup">
		<cfset cache = createobject("component", "restfulcf.framework.core.cache.AbstractCache")>
	</cffunction>

	<cffunction name="init_of_abstract_cache_should_fail">
		<cftry>
			<cfset cache.init()>
			<cfset fail("Call to init() of abstract cache should have failed but didn't")>
			<cfcatch type="RESTfulCF.AbstractCache.CannotInitAbstractCache"></cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="call_to_getkey_on_abstract_cache_should_fail">
		<cftry>
			<cfset cache.getKey("x")>
			<cfset fail("Call to getKey() of abstract cache should have failed but didn't")>
			<cfcatch type="RESTfulCF.AbstractCache.NotImplemented"></cfcatch>
		</cftry>
	</cffunction>
	<cffunction name="call_to_setkey_on_abstract_cache_should_fail">
		<cftry>
			<cfset cache.getKey("x", "x", 0)>
			<cfset fail("Call to setKey() of abstract cache should have failed but didn't")>
			<cfcatch type="RESTfulCF.AbstractCache.NotImplemented"></cfcatch>
		</cftry>
	</cffunction>
	<cffunction name="call_to_deletekey_on_abstract_cache_should_fail">
		<cftry>
			<cfset cache.deleteKey("x")>
			<cfset fail("Call to deleteKey() of abstract cache should have failed but didn't")>
			<cfcatch type="RESTfulCF.AbstractCache.NotImplemented"></cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="get_call_to_uncached_request_should_return_a_failed_lookup">
		<cfset var response = "">
		<cfset injectMethod(cache, this, "return_nothing", "getKey")>
		<cfset response = cache.get(createobject("component", "restfulcf.framework.core.Request"))>
		<cfset assertFalse(response.found)>
	</cffunction>
	<cffunction name="get_call_to_cached_request_should_return_response_object">
		<cfset var response = "">
		<cfset injectMethod(cache, this, "return_serialised_response", "getKey")>
		<cfset response = cache.get(createobject("component", "restfulcf.framework.core.Request"))>
		<cfset assertTrue(response.found, "Cache miss")>
		<cfset assertIsTypeOf(response.response, "restfulcf.framework.core.Response")>
		<cfset assertEquals(200, response.response.getStatusCode())>
		<cfset assertEquals("text/xml", response.response.getResponseType())>
		<cfset assertEquals("<fake></fake>", response.response.getResponseBody())>
	</cffunction>

	<cffunction name="set_should_call_setkey_with_the_correct_serialised_arguments">
		<cfset var args = {}>
		<cfset var vo   = {}>
		<cfset var key  = "">
		<cfset var kvp  = "">
		<cfset injectMethod(cache, this, "setkey_that_throws_exception_with_arguments", "setKey")>
		<cftry>
			<!--- use raw, non-init'd objects to get around dependencies --->
			<cfset cache.set(
				createobject("component", "restfulcf.framework.core.Request"),
				createobject("component", "restfulcf.framework.core.Response")
			)>
			<cfset fail("Should have received an exception from the mock setKey() function")>
			<cfcatch type="RESTfulCF.AbstractCacheTest.SetKeyTest">
				<cfset args = deserializejson(cfcatch.message)>
				<cfset assertEquals("_type=&_uri=/x-invalid-route&_verb=INVALID", args.key, "Cache key not as expected")>
				<cfset assertTrue(isdate(args.expires), "Expiry not a date")>
				<cfset assertTrue(args.expires GT now(), "Expiry not in the future")>
				<cfset vo = deserializejson(args.value)>
				<cfset assertIsStruct(vo, "Value not a JSON-encoded structure")>
				<cfloop list="status_text,response_type|application/xml,response_file,status_code|200,response_body,response_uri" index="key">
					<cfset kvp = listtoarray(key, "|")>
					<cfset assertTrue(structkeyexists(vo, kvp[1]), "Value key #kvp[1]# was expected but doesn't exist")>
					<cfif arraylen(kvp) EQ 1><cfset arrayappend(kvp, "")></cfif>
					<cfset assertEquals(kvp[2], vo[kvp[1]], "Value for key #kvp[1]# was incorrect")>
				</cfloop>
			</cfcatch>
		</cftry>
	</cffunction>

	<!--- injected functions used for mocking --->
	<cffunction name="return_nothing" access="private">
		<cfreturn "">
	</cffunction>
	<cffunction name="return_serialised_response" access="private">
		<cfset var response = {
			status_code   = 200,
			status_text   = "",
			response_type = "text/xml",
			response_uri  = "",
			response_body = "<fake></fake>",
			response_file = ""
		}>
		<cfreturn serializejson(response)>
	</cffunction>
	<cffunction name="setkey_that_throws_exception_with_arguments" access="private">
		<cfthrow type="RESTfulCF.AbstractCacheTest.SetKeyTest" message="#serializejson(arguments)#">
	</cffunction>

</cfcomponent>
