<!--- -->
<fusedoc fuse="restfulcf/test/tests/core/ResponseTest.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I test the response object
	</responsibilities>
</fusedoc>
--->

<cfcomponent extends="mxunit.framework.TestCase">

	<cffunction name="setup">
		<cfset response = createobject("component", "restfulcf.framework.core.Response").init()>
	</cffunction>

	<!--- initialisation --->
	<cffunction name="init_should_return_the_response_object">
		<cfset assertIsTypeOf(response, "restfulcf.framework.core.Response")>
	</cffunction>

	<!--- basic gets/sets --->
	<cffunction name="should_have_a_default_status_code_of_200">
		<cfset assertEquals(200, response.getStatusCode())>
	</cffunction>
	<cffunction name="should_have_a_default_response_type_of_application_xml">
		<cfset assertEquals("application/xml", response.getResponseType())>
	</cffunction>
	<cffunction name="should_return_the_correct_status_code_after_set">
		<cfset response.setStatusCode(500)>
		<cfset assertEquals(500, response.getStatusCode())>
	</cffunction>
	<cffunction name="should_return_the_correct_status_text_after_set">
		<cfset response.setStatusText("OK")>
		<cfset assertEquals("OK", response.getStatusText())>
	</cffunction>
	<cffunction name="should_return_the_correct_response_type_after_set">
		<cfset response.setResponseType("text/plain")>
		<cfset assertEquals("text/plain", response.getResponseType())>
	</cffunction>
	<cffunction name="should_return_the_correct_response_uri_after_set">
		<cfset response.setResponseURI("/test/1")>
		<cfset assertEquals("/test/1", response.getResponseURI())>
	</cffunction>
	<cffunction name="should_return_the_correct_response_body_after_set">
		<cfset response.setResponseBody("body")>
		<cfset assertEquals("body", response.getResponseBody())>
	</cffunction>

	<!--- error handling --->
	<cffunction name="should_have_no_errors_before_any_errors_have_been_added">
		<cfset assertFalse(response.hasErrors())>
	</cffunction>
	<cffunction name="should_have_errors_after_an_error_has_been_added">
		<cfset response.addError("Error 1")>
		<cfset assertTrue(response.hasErrors())>
	</cffunction>
	<cffunction name="should_return_an_empty_error_collection_without_errors">
		<cfset assertEquals(0, response.getErrorCollection().getErrorCount())>
	</cffunction>
	<cffunction name="should_return_a_populated_error_collection_with_errors">
		<cfset response.addError("Error 1")>
		<cfset assertEquals(1, response.getErrorCollection().getErrorCount())>
		<cfset response.addError("Error 2")>
		<cfset assertEquals(2, response.getErrorCollection().getErrorCount())>
	</cffunction>
	<cffunction name="should_return_an_error_collection_with_the_correct_errors">
		<cfset var err = []>
		<cfset response.addError("Error 1")>
		<cfset response.addError("Error 2")>
		<cfset err = response.getErrorCollection().getErrors()>
		<cfset assertEquals("Error 1", err[1])>
		<cfset assertEquals("Error 2", err[2])>
	</cffunction>

	<!--- cache handling --->
	<cffunction name="default_cache_status_should_be_false">
		<cfset assertFalse(response.getCacheStatus())>
	</cffunction>
	<cffunction name="cache_status_should_be_true_after_setting_to_true">
		<cfset response.setCacheStatus(TRUE)>
		<cfset assertTrue(response.getCacheStatus())>
	</cffunction>
	<cffunction name="default_cache_expiry_should_be_zero">
		<cfset assertEquals(0, response.getCacheExpiry())>
	</cffunction>
	<cffunction name="cache_expiry_should_be_correct_after_setting">
		<cfset var timeout = createtimespan(1,2,3,4)>
		<cfset response.setCacheExpiry(timeout)>
		<cfset assertEquals(timeout, response.getCacheExpiry())>
	</cffunction>
	<cffunction name="default_cache_hit_status_should_be_false">
		<cfset assertFalse(response.getCacheHit())>
	</cffunction>
	<cffunction name="cache_hit_status_should_be_true_after_setting_to_true">
		<cfset response.setCacheHit(TRUE)>
		<cfset assertTrue(response.getCacheHit())>
	</cffunction>
	<cffunction name="default_cache_key_should_be_empty">
		<cfset assertEquals("", response.getCacheKey())>
	</cffunction>
	<cffunction name="cache_key_should_be_correct_after_setting">
		<cfset var key = createuuid()>
		<cfset response.setCacheKey(key)>
		<cfset assertEquals(key, response.getCacheKey())>
	</cffunction>

</cfcomponent>
