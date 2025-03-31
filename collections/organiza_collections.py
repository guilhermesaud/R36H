import os
import re
from collections import defaultdict

def limpar_conteudo(linhas):
    """Remove linhas vazias e comentários, mantendo apenas conteúdo válido"""
    return [linha.strip() for linha in linhas 
           if linha.strip() and not linha.strip().startswith('#')]

def formatar_nome_genero(nome_arquivo):
    """Adiciona a tag [GENERO] ao nome do arquivo"""
    nome_genero = nome_arquivo[7:-4].replace('[GENERO]', '').strip()
    return f"custom-[GENERO] {nome_genero}.cfg"

def remover_linhas_vazias_arquivo(caminho_arquivo):
    """Remove linhas vazias de um arquivo existente"""
    with open(caminho_arquivo, 'r', encoding='utf-8') as f:
        linhas = f.readlines()
    
    linhas_limpas = [linha for linha in linhas if linha.strip()]
    
    with open(caminho_arquivo, 'w', encoding='utf-8') as f:
        f.writelines(linhas_limpas)

def consolidar_generos(diretorio_collections):
    # Mapeamento especial para casos específicos
    MAPEAMENTO_ESPECIAL = {
        # Corrida
        'custom-Corrida de cavalos.cfg': 'custom-Corrida.cfg',
        'custom-Corrida de moto em 3ª pessoa.cfg': 'custom-Corrida.cfg',
        'custom-Corrida em 3ª pessoa.cfg': 'custom-Corrida.cfg',
        'custom-Corrida, Pilotagem - Corrida.cfg': 'custom-Corrida.cfg',
        'custom-Corrida, Pilotagem.cfg': 'custom-Corrida.cfg',
        
        # Ação/Action
        'custom-Action.cfg': 'custom-Ação.cfg',
        'custom-Action, Fighting.cfg': 'custom-Ação.cfg',
        'custom-Action, Role-Playing, Fighting.cfg': 'custom-Ação.cfg',

        # RPG
        'custom-RPG de Ação.cfg': 'custom-RPG.cfg',
        'custom-Jogos de RPG.cfg': 'custom-RPG.cfg',
        'custom-Role-Playing.cfg': 'custom-RPG.cfg',
        'custom-Role-Playing, Sports.cfg': 'custom-RPG.cfg',
        
        # Briga de rua → Beat 'em up
        'custom-Briga de rua.cfg': 'custom-Beat \'em up.cfg',
        
        # Pesca → Caça e Pesca
        'custom-Pesca.cfg': 'custom-Caça e Pesca.cfg',
        
        # Strategy → Estratégia
        'custom-Strategy.cfg': 'custom-Estratégia.cfg',
        'custom-Estratégia.cfg': 'custom-Estratégia.cfg', 
        
        # Música e Dança + Rítmico → Música
        'custom-Música e dança.cfg': 'custom-Música.cfg',
        'custom-Rítmico.cfg': 'custom-Música.cfg',
        'custom-Música.cfg': 'custom-Música.cfg',

        # Educacional + Quiz + Reflexão → Variados
        'custom-Educacional.cfg': 'custom-Variados.cfg',
        'custom-Quiz.cfg': 'custom-Variados.cfg',
        'custom-Reflexão.cfg': 'custom-Variados.cfg',
        'custom-Variados.cfg': 'custom-Variados.cfg'
    }

    # Padrão para identificar subgêneros
    padrao_subgenero = re.compile(r'^custom-(.+?)( - |, | com | em |,|\.).+?\.cfg$')
    
    # Verificar se a pasta collections existe
    if not os.path.exists(diretorio_collections):
        print(f"\n❌ Erro: Pasta '{diretorio_collections}' não encontrada!")
        return False
    
    # Identificar todos os arquivos .cfg
    todos_arquivos = [f for f in os.listdir(diretorio_collections) 
                     if f.startswith('custom-') and f.endswith('.cfg')]
    
    if not todos_arquivos:
        print("\n⚠️  Nenhum arquivo de gênero encontrado!")
        return False
    
    print("\n=== INICIANDO ORGANIZAÇÃO ===")
    print(f"📂 Local: {os.path.abspath(diretorio_collections)}")
    
    # Primeiro: garantir que os arquivos principais existam
    for genero_principal in set(MAPEAMENTO_ESPECIAL.values()):
        caminho_principal = os.path.join(diretorio_collections, genero_principal)
        if not os.path.exists(caminho_principal):
            with open(caminho_principal, 'w', encoding='utf-8') as f:
                pass
            if genero_principal in todos_arquivos:
                todos_arquivos.remove(genero_principal)
            print(f"📄 Criado arquivo principal: {genero_principal}")

    # Processar mapeamento especial
    for arquivo, genero_principal in MAPEAMENTO_ESPECIAL.items():
        if arquivo in todos_arquivos and arquivo != genero_principal:
            caminho_arquivo = os.path.join(diretorio_collections, arquivo)
            caminho_principal = os.path.join(diretorio_collections, genero_principal)
            
            # Ler conteúdo do arquivo
            with open(caminho_arquivo, 'r', encoding='utf-8') as f:
                conteudo_limpo = limpar_conteudo(f.readlines())
            
            # Adicionar ao arquivo principal
            with open(caminho_principal, 'a+', encoding='utf-8') as f_principal:
                if os.path.getsize(caminho_principal) > 0 and conteudo_limpo:
                    f_principal.write("\n")
                f_principal.write("\n".join(conteudo_limpo))
            
            os.remove(caminho_arquivo)
            print(f"♻️  {arquivo:45} → consolidado em {genero_principal}")
            todos_arquivos.remove(arquivo)

    # Processar demais arquivos
    generos = defaultdict(list)
    for arquivo in todos_arquivos:
        match = padrao_subgenero.match(arquivo)
        if match:
            genero_principal = f"custom-{match.group(1)}.cfg"
            generos[genero_principal].append(arquivo)
        else:
            print(f"🔷 {arquivo:45} → mantido como principal")

    # Consolidar subgêneros restantes
    for genero_principal, subgeneros in generos.items():
        caminho_principal = os.path.join(diretorio_collections, genero_principal)
        
        conteudo_total = []
        if os.path.exists(caminho_principal):
            with open(caminho_principal, 'r', encoding='utf-8') as f:
                conteudo_total = limpar_conteudo(f.readlines())
        
        for subgenero in subgeneros:
            caminho_subgenero = os.path.join(diretorio_collections, subgenero)
            with open(caminho_subgenero, 'r', encoding='utf-8') as f:
                conteudo_total.extend(limpar_conteudo(f.readlines()))
            os.remove(caminho_subgenero)
            print(f"✅ {subgenero:45} → consolidado em {genero_principal}")
        
        # Escrever conteúdo garantindo que não haja linhas vazias consecutivas
        with open(caminho_principal, 'w', encoding='utf-8') as f:
            f.write("\n".join(conteudo_total))
        
        # Verificar e remover quaisquer linhas vazias que possam ter sobrado
        remover_linhas_vazias_arquivo(caminho_principal)

    # Aplicar a tag [GENERO] a todos os arquivos finais
    print("\n=== APLICANDO TAG [GENERO] ===")
    arquivos_finais = [f for f in os.listdir(diretorio_collections) 
                      if f.startswith('custom-') and f.endswith('.cfg')]
    
    for arquivo in arquivos_finais:
        novo_nome = formatar_nome_genero(arquivo)
        os.rename(
            os.path.join(diretorio_collections, arquivo),
            os.path.join(diretorio_collections, novo_nome)
        )
        print(f"🏷️  {arquivo:45} → {novo_nome}")
        
        # Verificar novamente após renomear
        caminho_arquivo = os.path.join(diretorio_collections, novo_nome)
        remover_linhas_vazias_arquivo(caminho_arquivo)

    return True

if __name__ == "__main__":
    DIRETORIO_COLLECTIONS = os.path.join(os.path.dirname(__file__), 'collections')
    
    print("\n" + "="*50)
    print(" ORGANIZADOR DE ARQUIVOS DE GÊNERO ".center(50, '='))
    print("="*50)
    
    if consolidar_generos(DIRETORIO_COLLECTIONS):
        print("\n✅ Concluído com sucesso! Arquivos finais:")
        for f in sorted(f for f in os.listdir(DIRETORIO_COLLECTIONS) 
                      if f.startswith('custom-') and f.endswith('.cfg')):
            print(f"→ {f}")
    
    input("\nPressione Enter para sair...")