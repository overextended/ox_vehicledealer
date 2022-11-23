return {
    label = 'Mosley Auto Service',
    sprite = 810,
    blip = vec(-47.9, -1681.8),
    components = {
        {
            name = 'Vehicle Yard',
            type = 'vehicleYard',
            vehicles = { automobile = true, bicycle = true, bike = true, quadbike = true },
            disableGenerators = true,
            thickness = 4.0,
            points = {
                vec3(-64.0, -1687.5, 29.0),
                vec3(-54.0, -1697.5, 29.0),
                vec3(-37.5, -1690.5, 29.0),
                vec3(-35.5, -1679.0, 29.0),
                vec3(-48.0, -1669.0, 29.0),
            },
            spawns = {
                vec(-40.3, -1688.5, 29.0, 55.6),
                vec(-51.7, -1677.7, 28.9, 259.8),
                vec(-47.6, -1691.3, 29.0, 46.0),
                vec(-51.0, -1692.7, 29.1, 43.5),
                vec(-56.7, -1684.0, 29.1, 262.1),
                vec(-54.6, -1694.2, 29.1, 45.7),
                vec(-39.2, -1678.5, 29.1, 230.5),
                vec(-44.1, -1690.0, 29.0, 49.1),
                vec(-59.3, -1687.2, 29.1, 264.3),
                vec(-54.2, -1680.8, 29.0, 260.5),
            },
        },
    },
}
