codeunit 13663 "OIOUBL-Fin Charg Memo Line Sub"
{
    [EventSubscriber(ObjectType::Table, 303, 'OnAfterInsertEvent', '', false, false)]
    procedure OnAfterInsertEventAccountCodeAssignment(var Rec: Record "Finance Charge Memo Line"; RunTrigger: Boolean);
    var
        FinChargeMemoHeader: Record "Finance Charge Memo Header";
    begin
        if not FinChargeMemoHeader.Get(Rec."Finance Charge Memo No.") then
            exit;

        Rec."OIOUBL-Account Code" := FinChargeMemoHeader."OIOUBL-Account Code";
        Rec.Modify();
    end;
}