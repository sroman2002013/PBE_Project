require 'mfrc522' # Requiere la librería para interactuar con el lector RFID-RC522

class Rfid
  def read_uid
    puts "Por favor, acerque su tarjeta al lector." # Pedimos al usuario que acerque su tarjeta para identificarse

    begin
      r = MFRC522.new # Creamos una instancia de MFRC522

      r.picc_request(MFRC522::PICC_REQA) # Enviamos una solicitud a la RFID para establecer comunicación

      uid_dec, _ = r.picc_select # Intentamos leer la UID y almacenamos en "uid_dec"

    rescue CommunicationError => e # Capturamos excepciones de comunicación
      puts "Error de comunicación: #{e.message}"
      retry # Reintentamos en caso de error
    end

    uid = uid_dec.map { |byte| byte.to_s(16).rjust(2, '0') }.join('').upcase # Convertimos el UID a hexadecimal y lo concatenamos

    return uid # Retornamos el UID en mayúsculas
  end
end

if __FILE__ == $0 # Para inicializar el programa
  rf = Rfid.new # Creamos una instancia de Rfid
  uid = rf.read_uid # Método para leer el UID de la tarjeta
  puts "UID: #{uid}" # Imprimimos el UID por pantalla
end
