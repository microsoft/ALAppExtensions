codeunit 40017 "Hybrid Handle Comp Init Error"
{
    TableNo = "Hybrid Company";
    trigger OnRun()
    begin
        Rec.Validate("Company Initialization Status", Rec."Company Initialization Status"::"Initialization Failed");
        Clear(Rec."Company Initialization Task");
        Rec.Modify();
        Rec.SetCompanyInitFailureMessage(GetLastErrorCallStack());
    end;
}