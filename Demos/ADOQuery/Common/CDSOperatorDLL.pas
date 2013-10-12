unit CDSOperatorDLL;

interface

uses
  uICDSOperator;

function createCDSEncode: ICDSEncode;stdcall;external 'CDSOperator.dll'; 
function createCDSDecode: ICDSDecode;stdcall;external 'CDSOperator.dll';

implementation

end.
