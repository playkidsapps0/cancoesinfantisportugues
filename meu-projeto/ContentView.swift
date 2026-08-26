import SwiftUI
import AVFoundation

struct CançaoModel: Identifiable {
    let id: UUID = UUID()
    let titulo: String
    let arquivo: String 
}

struct ContentView: View {
    let cancoes: [CançaoModel] = [
        CançaoModel(titulo: "Baratinha", arquivo: "baratinha"),
        CançaoModel(titulo: "Cão Amigo", arquivo: "cachorro"),
        CançaoModel(titulo: "Coelhinho", arquivo: "coelhinho"),
        CançaoModel(titulo: "Sapo Cururu", arquivo: "cururu"),
        CançaoModel(titulo: "A Dona Aranha", arquivo: "dona_aranha"),
        CançaoModel(titulo: "Seu Lobato", arquivo: "fazenda"),
        CançaoModel(titulo: "A Galinha Magricela", arquivo: "galinha"),
        CançaoModel(titulo: "Os Indiozinhos", arquivo: "indiozinhos"),
        CançaoModel(titulo: "Baile dos Passarinhos", arquivo: "passarinho"),
        CançaoModel(titulo: "Voa Voa Voa Passarinho", arquivo: "passarinhos"),
        CançaoModel(titulo: "Pintinho Amarelinho", arquivo: "pintinho"),
        CançaoModel(titulo: "O Sapo Não Lava o Pé", arquivo: "sapo_pe"),
        CançaoModel(titulo: "Querido Sol", arquivo: "sol")
    ]

    var body: some View {
        NavigationView {
            List(cancoes) { cancao in
                NavigationLink(destination: AudioPlayerView(cancao: cancao)) {
                    HStack {
                        Image(systemName: "music.note")
                            .foregroundColor(.blue)
                        Text(cancao.titulo)
                            .font(.headline)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Músicas Infantis")
        }
    }
}

struct AudioPlayerView: View {
    let cancao: CançaoModel
    
    @State private var player: AVAudioPlayer? = nil
    @State private var isPlaying: Bool = false
    @State private var imagemFundo: String = "fundo1"
    
    // Estados para controlar o tempo e o progresso da barra
    @State private var tempoAtual: TimeInterval = 0.0
    @State private var duracaoTotal: TimeInterval = 0.0
    
    // Timer para atualizar a interface a cada 0.5 segundos
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            if let path: String = Bundle.main.path(forResource: imagemFundo, ofType: "png"),
               let uiImage: UIImage = UIImage(contentsOfFile: path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
            } else {
                Color.black.edgesIgnoringSafeArea(.all)
            }

            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "music.note.list")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                Text(cancao.titulo)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                // BARRA DE PROGRESSO COM TEMPO ATUAL E TOTAL
                VStack(spacing: 8) {
                    Slider(value: Binding(
                        get: { tempoAtual },
                        set: { novoTempo in buscarTempoEspecífico(para: novoTempo) }
                    ), in: 0...max(duracaoTotal, 1))
                    .accentColor(.white)
                    .padding(.horizontal, 30)
                    
                    HStack {
                        Text(formatarTempo(tempoAtual))
                        Spacer()
                        Text(formatarTempo(duracaoTotal))
                    }
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 35)
                }
                
                // CONTROLES DE MÍDIA
                HStack(spacing: 40) {
                    Button(action: retrocederAudio) {
                        Image(systemName: "gobackward.15")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }

                    Button(action: togglePlay) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                    }

                    Button(action: avancarAudio) {
                        Image(systemName: "goforward.15")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            sortearImagemFundo()
            inicializarPlayer()
        }
        .onDisappear {
            player?.stop()
        }
        // Ouvinte do Timer que atualiza a barra enquanto a música toca
        .onReceive(timer) { _ in
            if let p = player, p.isPlaying {
                tempoAtual = p.currentTime
            }
        }
    }

    func sortearImagemFundo() {
        let fundos: [String] = ["fundo1", "fundo2"]
        if let sorteado = fundos.randomElement() {
            imagemFundo = sorteado
        }
    }

    func inicializarPlayer() {
        if let url: URL = Bundle.main.url(forResource: cancao.arquivo, withExtension: "mp3") {
            player = try? AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.prepareToPlay()
            player?.play()
            isPlaying = true
            
            // Define a duração total da música na interface
            if let p = player {
                duracaoTotal = p.duration
            }
        }
    }

    func togglePlay() {
        guard let player = player else { return }
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }

    func avancarAudio() {
        guard let player = player else { return }
        player.currentTime = min(player.currentTime + 15, player.duration)
        tempoAtual = player.currentTime
    }

    func retrocederAudio() {
        guard let player = player else { return }
        player.currentTime = max(player.currentTime - 15, 0)
        tempoAtual = player.currentTime
    }
    
    func buscarTempoEspecífico(para novoTempo: TimeInterval) {
        guard let player = player else { return }
        player.currentTime = novoTempo
        tempoAtual = novoTempo
    }
    
    // Converte segundos em formato de texto amigável (Ex: 95 segundos -> 01:35)
    func formatarTempo(_ tempo: TimeInterval) -> String {
        let minutos = Int(tempo) / 60
        let segundos = Int(tempo) % 60
        return String(format: "%02d:%02d", minutos, segundos)
    }
}

