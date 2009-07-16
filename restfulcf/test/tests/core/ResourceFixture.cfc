<!--- -->
<fusedoc fuse="restfulcf/test/tests/core/ResourceFixture.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I am a test resource
	</responsibilities>
</fusedoc>
--->

<cfcomponent extends="restfulcf.framework.core.Resource" output="no">

	<!--- standard 'model' fields --->
	<cfproperty name="id"                type="numeric"  default="1">
	<cfproperty name="name"              type="string"   default="Default">
	<cfproperty name="email"             type="string"   default="test@test.com">
	<cfproperty name="location">
	<cfproperty name="created_at"        type="date"     default="{ts '1978-09-22 00:00:00'}">
	<cfproperty name="updated_at"        type="date"     default="{ts '1978-09-22 00:00:00'}">

	<!--- 'foreign keys' (anything with _id is an integer by default)--->
	<cfproperty name="remote_id"                         default="2">
	<cfproperty name="numeric_id"        type="numeric"  default="3">
	<cfproperty name="decimal_id"        type="numeric"  default="3.45" precision="decimal">
	<cfproperty name="string_id"         type="string"   default="x">

	<!--- numeric preceision --->
	<cfproperty name="numeric"           type="numeric"  default="0.2e3"  precision="any">
	<cfproperty name="integer"           type="numeric"  default="3"      precision="integer">
	<cfproperty name="decimal"           type="numeric"  default="4.56"   precision="decimal">
	<cfproperty name="float"             type="numeric"  default="7.8"    precision="float">

	<!--- date precision --->
	<cfproperty name="date_only"         type="date"     default="{ts '1978-09-22 00:00:00'}"   precision="date">
	<cfproperty name="time_only"         type="date"     default="{ts '1978-09-22 12:34:56'}"   precision="time">
	<cfproperty name="date_and_time"     type="date"     default="{ts '1978-09-22 12:34:56'}"   precision="datetime">

	<!--- boolean coercing --->
	<cfproperty name="boolean"           type="boolean"  default="1">

</cfcomponent>
