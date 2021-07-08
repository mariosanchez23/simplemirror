Class User.Report.Record3 Extends (%Persistent, %XML.Adaptor) [ ProcedureBlock ]
{

Property orderid As %String [ SqlColumnNumber = 2 ];

Property data1 As %String [ SqlColumnNumber = 3 ];

Property data2 As %String [ SqlColumnNumber = 4 ];

Property memo As %String [ SqlColumnNumber = 5 ];

Index pkey On orderid [ Unique ];

Storage Default
{
<Data name="Record3DefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>orderid</Value>
</Value>
<Value name="3">
<Value>data1</Value>
</Value>
<Value name="4">
<Value>data2</Value>
</Value>
<Value name="5">
<Value>memo</Value>
</Value>
</Data>
<DataLocation>^User.Report.Record3D</DataLocation>
<DefaultData>Record3DefaultData</DefaultData>
<IdLocation>^User.Report.Record3D</IdLocation>
<IndexLocation>^User.Report.Record3I</IndexLocation>
<StreamLocation>^User.Report.Record3S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
