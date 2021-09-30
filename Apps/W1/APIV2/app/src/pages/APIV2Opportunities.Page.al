page 30070 "APIV2 - Opportunities"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Opportunity';
    EntitySetCaption = 'Oportunities';
    DelayedInsert = true;
    EntityName = 'opportunity';
    EntitySetName = 'opportunities';
    PageType = API;
    SourceTable = Opportunity;
    Extensible = false;
    ODataKeyFields = SystemId;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(number; "No.")
                {
                    Caption = 'No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("No."));
                    end;
                }
                field(contactNumber; "Contact No.")
                {
                    Caption = 'Contact No.';

                    trigger OnValidate()
                    begin
                        if (Rec.Status = Status::Won) or (Rec.Status = Status::Lost) then
                            Error(ContactNoCannotBeChangedWonLostErr);

                        RegisterFieldSet(FieldNo("Contact No."));
                    end;
                }
                field(contactName; "Contact Name")
                {
                    Caption = 'Contact Name';
                    Editable = false;
                }
                field(contactCompanyName; "Contact Company Name")
                {
                    Caption = 'Contact Company Name';
                    Editable = false;
                }
                field(salespersonCode; "Salesperson Code")
                {
                    Caption = 'Salesperson Code';

                    trigger OnValidate()
                    begin
                        if (Rec.Status = Status::Won) or (Rec.Status = Status::Lost) then
                            Error(SalespersonCodeCannotBeChangedErr);

                        RegisterFieldSet(FieldNo("Salesperson Code"));
                    end;
                }
                field(description; Description)
                {
                    Caption = 'Description';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo(Description));
                    end;
                }
                field(status; Status)
                {
                    Caption = 'Status';
                    Editable = false;
                }
                field(closed; Closed)
                {
                    Caption = 'Closed';
                    Editable = false;
                }
                field(creationDate; "Creation Date")
                {
                    Caption = 'Creation Date';
                    Editable = false;
                }
                field(dateClosed; "Date Closed")
                {
                    Caption = 'Date Closed';
                    Editable = false;
                }
                field(calculatedCurrentValue; "Calcd. Current Value (LCY)")
                {
                    Caption = 'Calculated Current Value (LCY)';
                    Editable = false;
                }
                field(chancesOfSuccessPrc; "Chances of Success %")
                {
                    Caption = 'Chances of Success %';
                    Editable = false;
                }
                field(completedPrc; "Completed %")
                {
                    Caption = 'Completed %';
                    Editable = false;
                }
                field(estimatedClosingDate; "Estimated Closing Date")
                {
                    Caption = 'Estimated Closing Date';
                    Editable = false;
                }
                field(estimatedValue; "Estimated Value (LCY)")
                {
                    Caption = 'Estimated Value (LCY)';
                    Editable = false;
                }
                field(systemCreatedAt; SystemCreatedAt)
                {
                    Caption = 'Creation Date';
                    Editable = false;
                }
                field(lastModifiedDateTime; SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    var
        TempFieldSet: Record 2000000041 temporary;
        SalespersonCodeCannotBeChangedErr: Label 'The "salespersonCode" of a Won or Lost Opportunity cannot be changed', Comment = 'salespersonCode is a field name and should not be translated';
        ContactNoCannotBeChangedWonLostErr: Label 'The "contactNumber of a Won or Lost Opportunity cannot be changed', Comment = 'contactNumber is a field name and should not be translated';

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.Get(Database::Item, FieldNo) then
            exit;

        TempFieldSet.Init();
        TempFieldSet.TableNo := Database::Item;
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.Insert(true);
    end;
}