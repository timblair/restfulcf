<!--- -->
<fusedoc fuse="restfulcf/framework/core/cache/ApplicationCache.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I am a concrete implementation of an abstract cache that uses the application scope.

		NOTE: You probably don't want to use this: there's no reaper, so it could end up being
		quite a memory hog, plus it's not the most efficient.  Just use it as an example of
		what you need to do to create your own concrete cache (using memcached or something
		similar, maybe...)
	</responsibilities>
</fusedoc>
--->

<cfcomponent extends="restfulcf.framework.core.cache.AbstractCache" output="no">

	<cffunction name="init" access="public" returntype="restfulcf.framework.core.cache.ApplicationCache" output="no" hint="Initialises this cache">
		<cfargument name="timeout" type="numeric" required="no" hint="">
		<cfset super.init(argumentcollection=arguments)>
		<cfif NOT structkeyexists(application['_restfulcf'], application.applicationname & "_cache")>
			<cfset application['_restfulcf'][application.applicationname & "_cache"] = {}>
		</cfif>
		<cfset variables.cache = application['_restfulcf'][application.applicationname & "_cache"]>
		<cfreturn this>
	</cffunction>

	<cffunction name="getKey" access="public" returntype="string" output="no" hint="Get a response from the cache">
		<cfargument name="key" type="string" required="yes" hint="The key to retrieve">
		<cfset var resp = "">
		<cfif structkeyexists(variables.cache, arguments.key)>
			<cfif structkeyexists(variables.cache[arguments.key], "expires") AND variables.cache[arguments.key].expires GT NOW()>
				<cfset resp = variables.cache[arguments.key].value>
			<cfelse>
				<cfset deleteKey(arguments.key)>
			</cfif>
		</cfif>
		<cfreturn resp>
	</cffunction>
	<cffunction name="setKey" access="public" returntype="string" output="no" hint="Sets a given value for a given key in the cache">
		<cfargument name="key" type="string" required="yes" hint="The key to set">
		<cfargument name="value" type="string" required="yes" hint="The value to store">
		<cfargument name="expires" type="numeric" required="yes" hint="The cache expiry date time">
		<cfset variables.cache[arguments.key] = { value = arguments.value, expires = arguments.expires }>
	</cffunction>
	<cffunction name="deleteKey" access="public" returntype="void" output="no" hint="Deletes a given key from the cache">
		<cfargument name="key" type="string" required="yes" hint="The key to delete">
		<cfset structdelete(variables.cache, arguments.key)>
	</cffunction>

</cfcomponent>
