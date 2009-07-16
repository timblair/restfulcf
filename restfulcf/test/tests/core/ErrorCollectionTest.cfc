<!--- -->
<fusedoc fuse="restfulcf/test/tests/core/ErrorCollectionTest.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I test the error collection component
	</responsibilities>
</fusedoc>
--->

<cfcomponent extends="mxunit.framework.TestCase">

	<cffunction name="setup">
		<cfset var errors = [ "Error 1", "Error 2", "Error 3" ]>
		<cfset empty = createobject("component", "restfulcf.framework.core.ErrorCollection")>
		<cfset collection = createobject("component", "restfulcf.framework.core.ErrorCollection").init(errors)>
	</cffunction>

	<cffunction name="base_init_should_return_instance_of_resource">
		<cfset assertIsTypeOf(empty, "restfulcf.framework.core.Resource")>
	</cffunction>
	<cffunction name="extended_init_should_return_instance_of_resource">
		<cfset assertIsTypeOf(collection, "restfulcf.framework.core.Resource")>
	</cffunction>

	<cffunction name="get_on_empty_collection_should_return_no_errors">
		<cfset assertEquals(0, arraylen(empty.getErrors()))>
	</cffunction>
	<cffunction name="count_on_empty_collection_should_return_a_zero_error_count">
		<cfset assertEquals(0, empty.getErrorCount())>
	</cffunction>

	<cffunction name="get_on_populated_collection_should_return_all_errors">
		<cfset assertEquals(3, arraylen(collection.getErrors()))>
	</cffunction>
	<cffunction name="count_on_populated_collection_should_a_correct_error_count">
		<cfset assertEquals(3, collection.getErrorCount())>
	</cffunction>
	<cffunction name="get_on_populated_collection_should_correct_errors">
		<cfset var errors = collection.getErrors()>
		<cfset var i = 0>
		<cfloop from="1" to="#arraylen(errors)#" index="i">
			<cfset assertEquals("Error #i#", errors[i])>
		</cfloop>
	</cffunction>

</cfcomponent>
