namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;

page 8065 "Assign Service Commitments"
{
    Caption = 'Assign Service Commitments';
    PageType = ListPlus;
    SourceTable = "Service Commitment Package";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    ShowFilter = false;
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                Visible = not OpenedFromSalesLine;
                field(FieldServiceAndCalculationStartDate; ServiceAndCalculationStartDate)
                {
                    Caption = 'Service and Calculation Start Date';
                    ToolTip = 'Specifies the date from which the service(s) are valid and should be calculated. The date is taken over when services are created as Service Start Date and Next Calculation Date.';
                }
                field(ItemNo; ServiceObject."Item No.")
                {
                    Editable = false;
                    Caption = 'Item No.';
                    ToolTip = 'Specifies the Item No. of the service object.';
                }
            }
            repeater(RepeaterControl)
            {
                field("Code"; Rec.Code)
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies a code to identify this service commitment package.';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the service commitment package.';
                    Editable = false;

                }
            }
            part(PackageLines; "Service Comm. Package Lines")
            {
                Editable = false;
                SubPageLink = "Package Code" = field(Code);
                UpdatePropagation = Both;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if Rec.IsEmpty() then
            exit;
        CurrPage.Update(false);
    end;

    var
        ServiceObject: Record "Service Object";
        SalesLine: Record "Sales Line";
        OpenedFromSalesLine: Boolean;
        ServiceAndCalculationStartDate: Date;

    internal procedure SetServiceObject(NewServiceObject: Record "Service Object")
    begin
        ServiceObject := NewServiceObject;
    end;

    internal procedure SetSalesLine(NewSalesLine: Record "Sales Line")
    begin
        SalesLine := NewSalesLine;
        OpenedFromSalesLine := true;
    end;

    internal procedure GetSelectionFilter(var ServiceCommitmentPackage: Record "Service Commitment Package")
    begin
        CurrPage.SetSelectionFilter(ServiceCommitmentPackage);
    end;

    internal procedure GetServiceAndCalculationStartDate(): Date
    begin
        exit(ServiceAndCalculationStartDate);
    end;
}