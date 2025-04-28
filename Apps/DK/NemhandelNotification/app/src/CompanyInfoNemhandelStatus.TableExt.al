namespace Microsoft.EServices;

using Microsoft.Foundation.Company;

tableextension 13608 "Company Info. Nemhandel Status" extends "Company Information"
{
    fields
    {
        field(13608; "Registered with Nemhandel"; Enum "Nemhandel Company Status")
        {
            DataClassification = OrganizationIdentifiableInformation;
            Editable = false;
        }
        field(13609; "Last Nemhandel Status Check DT"; DateTime)
        {
            DataClassification = SystemMetadata;
            Editable = false;
        }

        modify("Registration No.")
        {
            trigger OnBeforeValidate()
            begin
                if not NemhandelStatusMgt.IsSaaSProductionCompany() then
                    exit;

                NemhandelStatusMgt.ValidateCVRNumberFormat("Registration No.");

                if "Registered with Nemhandel" = "Nemhandel Company Status"::Registered then begin
                    if Rec."Registration No." <> xRec."Registration No." then
                        Error(CannotChangeRegistrationNoErr);
                    exit;
                end;

                "Registered with Nemhandel" := "Nemhandel Company Status"::Unknown;
                if CurrFieldNo = FieldNo("Registration No.") then
                    exit;       // run page background task instead
                if TaskScheduler.CanCreateTask() then
                    TaskScheduler.CreateTask(Codeunit::"Upd. Registered with Nemhandel", 0);
            end;

            trigger OnAfterValidate()
            begin
                if Rec."Registration No." <> '' then
                    NemhandelStatusMgt.ManageIncorrectCVRFormatNotification(Rec."Registration No.");
            end;
        }
    }

    var
        NemhandelStatusMgt: Codeunit "Nemhandel Status Mgt.";
        CannotChangeRegistrationNoErr: Label 'Registration No. cannot be changed when CVR number is registered in Nemhandelsregisteret.';
}