unit CDSOperatorDLL;

interface

uses
  uICDSOperator;

function createCDSEncode: ICDSEncode;stdcall;external 'libs\CDSOperator.dll';
function createCDSDecode: ICDSDecode;stdcall;external 'libs\CDSOperator.dll';

implementation

end.
