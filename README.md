# CadastroPessoa

Delphi na prática:

Projeto para cadastro de pessoas (campos: nome, data nascimento e saldo devedor). Os dados do projeto são salvos, em um primeiro momento serão em memória e depois são gravados/buscados a partir do banco de dados.
A aplicação permite:
> Gravar o cadastro em memória permite gravar N registros em memória;

> Gravar cadastros, que estão em memória, no banco de dados;

> Excluir cadastro no banco de dados a partir de um id;

> Carregar cadastros do banco de dados para memória;

> Mostrar todos os cadastros "gravados" em memória.

Além disso, alguns dados vem do consumo da API: https://developers.silbeck.com.br/mocks/apiteste/v2/aptos

A Aplicação foi desenvolvida com Delphi 10.1, SQLServer; conexão via FireDAC; recebe os dados via JSONObject. Além disso, foi desenvolvida seguindo o padrão de Programação Orientada a Objeto, e organizada baseando-se no padrão de arquitetura Model-View-ViewModel.
