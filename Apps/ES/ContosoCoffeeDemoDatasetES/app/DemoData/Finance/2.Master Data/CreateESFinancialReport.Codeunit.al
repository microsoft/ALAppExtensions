codeunit 10792 "Create ES Financial Report"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Financial Report", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertFinancialReport(var Rec: Record "Financial Report")
    var
        CreateFinancialReport: Codeunit "Create Financial Report";
        CreateColumnLayoutName: Codeunit "Create Column Layout Name";
    begin
        case Rec.Name of
            CreateFinancialReport.CapitalStructure():
                Rec.Validate("Financial Report Column Group", CreateColumnLayoutName.DefaultLayout());
        end;
    end;
}