page 31209 "Registration No. Check CZL"
{
    Caption = 'Registration No. Check';
    PageType = StandardDialog;
    ShowFilter = false;

    layout
    {
        area(content)
        {
            group(Control3)
            {
                ShowCaption = false;
                field("Registration No"; RegistrationNo)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Registration No.';
                    ToolTip = 'Specifies the registration number of partner.';

                    trigger OnValidate()
                    begin
                        DataTypeManagement.FindFieldByName(GlobalRecordRef, FieldRefVar, DummyCustomer.FieldName("Registration No. CZL"));
                        FieldRefVar.Validate(RegistrationNo);
                    end;
                }
            }
        }
    }

    actions
    {
    }

    var
        DummyCustomer: Record Customer;
        DataTypeManagement: Codeunit "Data Type Management";
        FieldRefVar: FieldRef;
        GlobalRecordRef: RecordRef;
        RegistrationNo: Text;

    procedure SetRecordRef(RecordVariant: Variant)
    begin
        DataTypeManagement.GetRecordRef(RecordVariant, GlobalRecordRef);
    end;

    procedure GetRecordRef(var RecordRef: RecordRef)
    begin
        RecordRef := GlobalRecordRef;
    end;
}

