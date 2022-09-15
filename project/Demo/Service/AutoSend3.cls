Class Demo.Service.AutoSend3 Extends Ens.BusinessService [ Language = objectscript ]
{

Parameter ADAPTER = "Ens.InboundAdapter";

Method OnProcessInput(pInput As %RegisteredObject, Output pOutput As %RegisteredObject) As %Status
{
	Set tSC=$$$OK
	Try {
		Set pRequest=##class(Ens.StringContainer).%New()
		Set orderid=$INCREMENT(^orderid3)
		Set pRequest.StringValue={"OrderId":(orderid),"TimeStamp":($ZDATETIME($H,3))}.%ToJSON()
		Set tSC=..SendRequestSync("RoutingEngine",pRequest)
		$$$ThrowOnError(tSC)
	}
	Catch e {
		Set tSC=e.AsStatus()
	}
	
	Return tSC
}

}
