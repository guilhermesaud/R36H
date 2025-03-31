import os
import xml.etree.ElementTree as ET

# Obtém o diretório onde o script está sendo executado
diretorio_principal = os.path.dirname(os.path.abspath(__file__))

# Define a pasta collections
collections_dir = os.path.join(diretorio_principal, "collections")
os.makedirs(collections_dir, exist_ok=True)  # Cria a pasta se não existir

# Dicionário para armazenar os jogos por gênero
generos_dict = {}
sem_genero = []  # Lista para armazenar jogos sem gênero

# Percorre todas as pastas dentro do diretório principal
for pasta in os.listdir(diretorio_principal):
    caminho_pasta = os.path.join(diretorio_principal, pasta)
    gamelist_path = os.path.join(caminho_pasta, "gamelist.xml")

    # Verifica se é uma pasta e se o arquivo gamelist.xml existe
    if os.path.isdir(caminho_pasta) and os.path.exists(gamelist_path):
        print(f"Lendo {gamelist_path}...")  # Verifica se encontrou o arquivo

        tree = ET.parse(gamelist_path)
        root = tree.getroot()

        # Percorre os jogos dentro do gamelist.xml
        for game in root.findall("game"):
            path_elem = game.find("path")
            genre_elem = game.find("genre")

            if path_elem is not None:
                jogo_path = path_elem.text.strip().replace("./", f"/roms/{pasta}/")

                if genre_elem is not None and genre_elem.text.strip():
                    genero = genre_elem.text.strip()
                    genero_safe = genero.replace("/", "-")  # Corrige nome do gênero

                    if genero_safe not in generos_dict:
                        generos_dict[genero_safe] = []
                    generos_dict[genero_safe].append(jogo_path)
                else:
                    # Se não tem gênero, adiciona na lista de "Sem Gênero"
                    sem_genero.append(jogo_path)

# Gera os arquivos de gênero na pasta collections
for genero, jogos in generos_dict.items():
    arquivo_genero = os.path.join(collections_dir, f"custom-{genero}.cfg")
    with open(arquivo_genero, "w", encoding="utf-8") as f:
        for jogo in jogos:
            f.write(jogo + "\n")

# Cria o arquivo para os jogos sem gênero
if sem_genero:
    arquivo_sem_genero = os.path.join(collections_dir, "custom-Sem Genero.cfg")
    with open(arquivo_sem_genero, "w", encoding="utf-8") as f:
        for jogo in sem_genero:
            f.write(jogo + "\n")

print("Arquivos de coleção gerados com sucesso!")
input("Pressione Enter para sair...")  # Mantém a janela aberta no Windows
