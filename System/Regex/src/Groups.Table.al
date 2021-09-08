// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides a representation of Regex Groups that models Group objects in .Net
/// </summary>
/// <remark>
/// For more information, visit https://docs.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.group?view=netcore-3.1.
/// </remark>
table 3964 Groups
{
    TableType = Temporary;
    Extensible = false;

    fields
    {
        field(1; GroupIndex; Integer)
        {
            Caption = 'Group Index';
            DataClassification = SystemMetadata;
        }
        field(2; Index; Integer)
        {
            DataClassification = SystemMetadata;
            Description = 'The position in the original string where the first character of the captured substring is found.';
        }
        field(3; Name; Text[2048])
        {
            DataClassification = SystemMetadata;
            Description = 'Returns the name of the capturing group represented by the current instance.';
        }
        field(4; ValueBlob; Blob)
        {
            Caption = 'Values';
            Access = Internal;
            DataClassification = SystemMetadata; // Since this is a temp table we can do this
            Description = 'Gets the captured substring from the input string.';
        }
        field(5; Length; Integer)
        {
            DataClassification = SystemMetadata;
            Description = 'Gets the length of the captured substring.';
        }
        field(6; Success; Boolean)
        {
            DataClassification = SystemMetadata;
            Description = 'Gets a value indicating whether the match is successful.';
        }
    }
    keys
    {
        key(PrimaryKey; GroupIndex)
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// Reads the value of the group 
    /// </summary>
    /// <returns>The value of the group.</returns>
    procedure ReadValue() TextValue: Text
    var
        ValueInStream: InStream;
    begin
        Rec.CalcFields(ValueBlob);
        Rec.ValueBlob.CreateInStream(ValueInStream, TextEncoding::UTF8);
        ValueInStream.Read(TextValue);
    end;

    internal procedure InsertValue(TextValue: Text)
    var
        ValueOutStream: OutStream;
    begin
        Rec.ValueBlob.CreateOutStream(ValueOutStream, TextEncoding::UTF8);
        ValueOutStream.Write(TextValue);
    end;
}