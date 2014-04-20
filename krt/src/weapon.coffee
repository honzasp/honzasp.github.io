define [], () ->
  Weapon = (@spec) ->
    @temperature = 0

  Weapon.FRAGMENT_RADIUS = 0.02
  Weapon.FIRE_SOUND_GAIN = 0.9

  Weapon.MachineGun = 
    name: "machine gun"
    bullet:
      speed: 120, time: 1, mass: 0.5
      radius: 0.1, color: "#ecb120"
      hurt: 20, damage: 0.1
      boom: 
        count: 8, speed: 20, time: 0.2
        radius: 0.2, color: "#e9ca2d", opacity: 0.6
    energy: 0.5
    cooldown: 0.05
    angleVariance: 2*Math.PI / 70
    sound: "shoot_machine_gun"

  Weapon.MiningGun =
    name: "mining gun"
    bullet:
      speed: 40, time: 2, mass: 5
      radius: 0.2, color: "#e337e6"
      hurt: 50, damage: 8
      boom:
        count: 25, speed: 60, time: 0.5
        radius: 0.7, color: "#af4fca", opacity: 0.5
        sound: "boom_mining_gun"
      fragment:
        speed: 50, time: 0.5, mass: 0.2
        radius: 0.2, color: "#c637e6"
        hurt: 10, damage: 2
        boom:
          count: 8, speed: 40, time: 0.3
          radius: 0.4, color: "#a044d9", opacity: 0.4
    energy: 8
    cooldown: 0.6
    angleVariance: 2*Math.PI / 70
    sound: "shoot_mining_gun"

  Weapon.EmergencyGun =
    name: "emergency gun"
    bullet:
      speed: 80, time: 1, mass: 0
      radius: 0.1, color: "#567aea"
      hurt: 2, damage: 0.1
      boom: 
        count: 5, speed: 20, time: 0.2
        radius: 0.15, color: "#446ae1", opacity: 0.4
    energy: 0.1
    cooldown: 0.1
    angleVariance: 2*Math.PI / 50
    sound: "shoot_emergency_gun"

  Weapon.Autocannon =
    name: "autocannon"
    bullet:
      speed: 80, time: 2, mass: 5
      radius: 0.15, color: "#e97a2d"
      hurt: 240, damage: 2
      boom: 
        count: 10, speed: 40, time: 0.2
        radius: 0.4, color: "#f1a94e", opacity: 0.6
        sound: "boom_autocannon"
      fragment:
        speed: 150, time: 0.5, mass: 0.25
        radius: 0.05, color: "#f36b24"
        hurt: 10, damage: 0.1
        boom: 
          count: 5, speed: 30, time: 0.1
          radius: 0.1, color: "#ec440d", opacity: 0.6
    energy: 3.5
    cooldown: 0.5
    angleVariance: 2*Math.PI / 80
    sound: "shoot_autocannon"

  Weapon.HugeCannon =
    name: "huge cannon"
    bullet:
      speed: 60, time: 5, mass: 15
      radius: 0.2, color: "#ed1895"
      hurt: 700, damage: 10
      boom:
        count: 30, speed: 40, time: 0.4
        radius: 0.8, color: "#d70b22", opacity: 0.6
        sound: "boom_huge_cannon"
      fragment:
        speed: 200, time: 0.15, mass: 0.4
        radius: 0.05, color: "#f23ca7"
        hurt: 20, damage: 0.5
        boom:
          count: 8, speed: 30, time: 0.3
          radius: 0.3, color: "#e75434", opacity: 0.6
    energy: 10
    cooldown: 2
    angleVariance: 2*Math.PI / 100 
    sound: "shoot_huge_cannon"

  Weapon
