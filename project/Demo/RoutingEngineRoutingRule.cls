/// 
Class Demo.RoutingEngineRoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.MsgRouter.RoutingEngine" production="Demo.Production">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="">
<when condition="Source=&quot;AutoSend&quot;">
<send transform="" target="StoreLocalDB"></send>
</when>
<when condition="Source=&quot;AutoSend2&quot;">
<send transform="" target="StoreLocalDB2"></send>
</when>
<when condition="Source=&quot;AutoSend3&quot;">
<send transform="" target="StoreLocalDB3"></send>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
