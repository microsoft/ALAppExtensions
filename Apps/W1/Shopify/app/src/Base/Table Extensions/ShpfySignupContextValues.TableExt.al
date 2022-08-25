/// <summary>
/// Table extension for the Signup Context values
/// </summary>
tableextension 30199 "Shpfy Signup Context Values" extends "Signup Context Values"
{
    fields
    {
        field(30100; "Shpfy Signup Shop Url"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'Signup Shop Url';
            Access = Internal;
        }
    }
}