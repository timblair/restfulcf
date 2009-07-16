<!--- -->
<fusedoc fuse="restfulcf/test/tests/util/ArrayMergeFixture.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I am a fixture component that allows testing of merging arrays containing component instances
	</responsibilities>
</fusedoc>
--->

<cfcomponent>

	<cfset this.id = 0>

	<cffunction name="init" access="public" returntype="ArrayMergeFixture" output="no">
		<cfargument name="id" type="numeric" required="yes">
		<cfset this.id = arguments.id>
		<cfreturn this>
	</cffunction>

	<cffunction name="getID" access="public" returntype="numeric" output="no">
		<cfreturn this.id>
	</cffunction>

</cfcomponent>