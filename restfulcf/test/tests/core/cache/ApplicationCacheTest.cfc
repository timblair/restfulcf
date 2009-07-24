<!--- -->
<fusedoc fuse="restfulcf/test/tests/core/cache/ApplicationCacheTest.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I test the application-scope cache
	</responsibilities>
</fusedoc>
--->

<cfcomponent extends="mxunit.framework.TestCase">

	<cffunction name="setup">
		<cfapplication name="restfulcf_test_cache_applicationcache">
		<cfset application['_restfulcf'] = {}>
		<cfset cache = createobject("component", "restfulcf.framework.core.cache.ApplicationCache").init()>
		<cfset cache_args = {
			key     = createuuid(),
			value   = createuuid(),
			expires = dateadd('s', 100, now())
		}>
	</cffunction>

	<cffunction name="getting_any_non_existent_key_should_return_an_empty_string">
		<cfset var i = 0>
		<cfloop from="1" to="10" index="i">
			<cfset assertEquals("", cache.getKey(createuuid()))>
		</cfloop>
	</cffunction>

	<cffunction name="correct_key_should_be_returned_after_setting_a_key">
		<cfset cache.setKey(argumentcollection=cache_args)>
		<cfset assertEquals(cache_args.value, cache.getKey(cache_args.key))>
	</cffunction>
	<cffunction name="key_should_not_exist_after_deleting_it">
		<cfset cache.setKey(argumentcollection=cache_args)>
		<cfset assertEquals(cache_args.value, cache.getKey(cache_args.key))>
		<cfset cache.deleteKey(cache_args.key)>
		<cfset assertEquals("", cache.getKey(cache_args.key))>
	</cffunction>
	<cffunction name="key_with_expiry_in_the_past_should_not_available">
		<cfset cache_args.expires = dateadd('s', -1, now())>
		<cfset cache.setKey(argumentcollection=cache_args)>
		<cfset assertEquals("", cache.getKey(cache_args.key))>
	</cffunction>

</cfcomponent>
