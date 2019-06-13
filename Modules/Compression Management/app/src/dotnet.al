// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

dotnet
{
    assembly("System.IO.Compression")
    {
        Version='4.0.0.0';
        Culture='neutral';
        PublicKeyToken='b77a5c561934e089';

        type("System.IO.Compression.ZipArchive";"ZipArchive")
        {
        }

        type("System.IO.Compression.ZipArchiveMode";"ZipArchiveMode")
        {
        }

        type("System.IO.Compression.ZipArchiveEntry";"ZipArchiveEntry")
        {
        }
    }

    assembly("mscorlib")
    {
        type("System.IO.Stream";"Stream")
        {
        }

        type("System.IO.StreamReader"; "StreamReader")
        {
        }
    }

}
