var
  LinhaAtual: Integer;

procedure MasterData1OnBeforePrint(Sender: TfrxComponent);
begin
  // Incrementa o contador de linhas
  LinhaAtual := LinhaAtual + 1;

  // Verifica se a linha é ímpar ou par e altera a cor
  if (LinhaAtual mod 2 = 0) then
    Memo9.Color := $00D8D8D8  // Linha par, cor azul
  else
    Memo9.Color := $00F0F0F0;  // Linha ímpar, cor vermelha

  if (LinhaAtual mod 2 = 0) then
    Memo11.Color := $00D8D8D8  // Linha par, cor azul
  else
    Memo11.Color := $00F0F0F0;  // Linha ímpar, cor vermelha            
end;

procedure Memo11OnBeforePrint(Sender: TfrxComponent);
begin

end;

begin
  LinhaAtual := 0; // Inicializa o contador de linhas
end.