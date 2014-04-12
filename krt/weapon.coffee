define [], () ->
  Weapon = (@spec) ->
    @temperature = 0

  Weapon.FRAGMENT_RADIUS = 0.02

  Weapon.MachineGun = 
    name: "machine gun"
    bullet:
      speed: 120
      time: 1
      radius: 0.1
      color: "#ecb120"
      mass: 0.5
      damage: 2.5
      boom: 
        count: 8, speed: 20, time: 0.2
        radius: 0.2, color: "#e9ca2d", opacity: 0.6
    energy: 0.5
    cooldown: 0.05
    angleVariance: 2*Math.PI / 50

  Weapon.Autocannon =
    name: "autocannon"
    bullet:
      speed: 80
      time: 2
      radius: 0.15
      color: "#e97a2d"
      mass: 5
      damage: 10
      boom: 
        count: 10, speed: 40, time: 0.2
        radius: 0.4, color: "#f1a94e", opacity: 0.6
      fragment:
        speed: 150
        time: 0.5
        radius: 0.05
        color: "#f36b24"
        mass: 0.25
        damage: 1
        boom: 
          count: 5, speed: 30, time: 0.1
          radius: 0.1, color: "#ec440d", opacity: 0.6
    energy: 3.5
    cooldown: 0.5
    angleVariance: 2*Math.PI / 80

  Weapon.HugeCannon =
    name: "huge cannon"
    bullet:
      speed: 60
      time: 5
      radius: 0.2
      color: "#ed1895"
      mass: 20
      damage: 10
      boom:
        count: 30, speed: 40, time: 0.4
        radius: 0.8, color: "#d70b22", opacity: 0.6
      fragment:
        speed: 200
        time: 0.15
        radius: 0.05
        color: "#f23ca7"
        mass: 0.5
        damage: 1
        boom:
          count: 8, speed: 30, time: 0.3
          radius: 0.3, color: "#e75434", opacity: 0.6
    energy: 5
    cooldown: 2
    angleVariance: 2*Math.PI / 100 

  Weapon
