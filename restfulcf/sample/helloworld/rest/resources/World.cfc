<!--- -->
<fusedoc fuse="restfulcf/sample/helloworld/rest/resources/World.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I am an example resource descriptor for a world for the "Hello World" sample app
	</responsibilities>
</fusedoc>
--->

<cfcomponent extends="restfulcf.framework.core.Resource" output="no">

	<!--- resource property fields: setter/getter methods for these properties are
	      automatically "created" via onMissingMethod; we could optionally provide
	      precision levels for numeric and date fields (id is automatically an int) --->
	<cfproperty name="id"               type="numeric"   default="0">
	<cfproperty name="name"             type="string"    default="">
	<cfproperty name="created_at"       type="date"      default="{ts '1900-01-01 00:00:00'}">
	<cfproperty name="updated_at"       type="date"      default="{ts '1900-01-01 00:00:00'}">

	<!--- an example of overriding a default representation of this resource type --->
	<cffunction name="toTXT" access="public" returntype="string" output="no" hint="Outputs a textual representation of this world">
		<cfreturn variables.instance.name & " world">
	</cffunction>

	<!--- an example of extending the world resource and adding an additional representation --->
	<cffunction name="toPDF" access="public" returntype="string" output="no" hint="Outputs a PDF representation of this world">
		<cfset var pdf = "">
		<cfsavecontent variable="pdf">
			<cfdocument format="pdf">
				<cfoutput>#variables.instance.name# world</cfoutput>
			</cfdocument>
		</cfsavecontent>
		<cfreturn pdf>
	</cffunction>

</cfcomponent>
