namespace Microsoft.SubscriptionBilling;

codeunit 8014 "Session Store"
{
    Access = Internal;
    SingleInstance = true;

    var
        BooleanDictionary: Dictionary of [Text, Boolean];

    internal procedure SetBooleanKey(KeyName: Text; BooleanValue: Boolean)
    begin
        if BooleanDictionary.ContainsKey(KeyName) then
            BooleanDictionary.Set(KeyName, BooleanValue)
        else
            BooleanDictionary.Add(KeyName, BooleanValue);
    end;

    internal procedure GetBooleanKey(KeyName: Text): Boolean
    begin
        if BooleanDictionary.ContainsKey(KeyName) then
            exit(BooleanDictionary.Get(KeyName));
    end;

    internal procedure RemoveBooleanKey(KeyName: Text)
    begin
        if BooleanDictionary.ContainsKey(KeyName) then
            BooleanDictionary.Remove(KeyName);
    end;
}