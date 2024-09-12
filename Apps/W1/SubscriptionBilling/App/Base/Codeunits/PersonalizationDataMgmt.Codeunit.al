namespace Microsoft.SubscriptionBilling;

using System.Environment.Configuration;

codeunit 8020 "Personalization Data Mgmt."
{
    Access = Internal;
    procedure SetDataPagePersonalization(ObjectType: Option ,,,Report,,,XMLport,,Page; ObjectID: Text; ValueName: Code[40]; Value: Text)
    var
        PageDataPersonalization: Record "Page Data Personalization";
        BigText: BigText;
        OutStream: OutStream;
        ObjectNo: Integer;
    begin
        PageDataPersonalization."User SID" := UserSecurityId();
        PageDataPersonalization."Object Type" := ObjectType;
        ObjectID := CopyStr(ObjectID, StrPos(ObjectID, ' ') + 1);
        Evaluate(ObjectNo, ObjectID);
        PageDataPersonalization."Object ID" := ObjectNo;
        PageDataPersonalization."Personalization ID" := CopyStr(ObjectID, 1, MaxStrLen(PageDataPersonalization."Personalization ID"));
        PageDataPersonalization.ValueName := ValueName;
        BigText.AddText(Value);
        PageDataPersonalization.Value.CreateOutStream(OutStream, TextEncoding::UTF8);
        BigText.Write(OutStream);
        if not PageDataPersonalization.Insert(false) then
            PageDataPersonalization.Modify(false);
    end;

    procedure GetDataPagePersonalization(ObjectType: Option ,,,Report,,,XMLport,,Page; ObjectID: Text; ValueName: Code[40]; var Value: Text): Boolean
    var
        PageDataPersonalization: Record "Page Data Personalization";
        BigText: BigText;
        InStream: InStream;
    begin
        FilterPageDataPersonalization(PageDataPersonalization, ObjectType, ObjectID, ValueName);
        PageDataPersonalization.SetAutoCalcFields(Value);
        if PageDataPersonalization.FindFirst() then begin
            PageDataPersonalization.Value.CreateInStream(InStream, TextEncoding::UTF8);
            BigText.Read(InStream);
            BigText.GetSubText(Value, 1);
            exit(true);
        end else
            exit(false);
    end;

    procedure DeleteDataPagePersonalization(ObjectType: Option ,,,Report,,,XMLport,,Page; ObjectID: Text; ValueName: Code[40])
    var
        PageDataPersonalization: Record "Page Data Personalization";
    begin
        FilterPageDataPersonalization(PageDataPersonalization, ObjectType, ObjectID, ValueName);
        if not PageDataPersonalization.IsEmpty() then
            PageDataPersonalization.DeleteAll(false);
    end;

    local procedure FilterPageDataPersonalization(var PageDataPersonalization2: Record "Page Data Personalization"; ObjectType: Option ,,,Report,,,XMLport,,Page; ObjectID: Text; ValueName: Code[40])
    var
        ObjectNo: Integer;
    begin
        PageDataPersonalization2.SetRange("User SID", UserSecurityId());
        PageDataPersonalization2.SetRange("Object Type", ObjectType);
        ObjectID := CopyStr(ObjectID, StrPos(ObjectID, ' ') + 1);
        Evaluate(ObjectNo, ObjectID);
        PageDataPersonalization2.SetRange("Object ID", ObjectNo);
        PageDataPersonalization2.SetRange("Personalization ID", ObjectID);
        PageDataPersonalization2.SetRange(ValueName, ValueName);
    end;
}