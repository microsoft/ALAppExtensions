namespace Microsoft.Manufacturing.PowerBIReports;

using Microsoft.PowerBIReports;

tableextension 36954 "Setup - Manufacturing" extends "PowerBI Reports Setup"
{
    fields
    {
        field(36958; "Manufacturing Load Date Type"; Option)
        {
            Caption = 'Manufacturing Report Load Date Type';
            OptionCaption = ' ,Start/End Date,Relative Date';
            OptionMembers = " ","Start/End Date","Relative Date";
            DataClassification = CustomerContent;
        }
        field(36959; "Manufacturing Start Date"; Date)
        {
            Caption = 'Manufacturing Report Start Date';
            DataClassification = CustomerContent;
        }
        field(36960; "Manufacturing End Date"; Date)
        {
            Caption = 'Manufacturing Report End Date';
            DataClassification = CustomerContent;
        }
        field(36961; "Manufacturing Date Formula"; DateFormula)
        {
            Caption = 'Manufacturing Report Date Formula';
            DataClassification = CustomerContent;
        }
        field(36978; "Manufacturing Report Id"; Guid)
        {
            Caption = 'Manufacturing Report ID';
            DataClassification = CustomerContent;
        }
        field(36979; "Manufacturing Report Name"; Text[200])
        {
            Caption = 'Manufacturing Report Name';
            DataClassification = CustomerContent;
        }
    }
}