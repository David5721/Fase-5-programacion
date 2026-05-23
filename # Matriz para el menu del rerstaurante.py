# Matriz para el menu del rerstaurante
menu = [
    ["casuela de frijoles", "Comida", 35000],
    ["ajiaco", "Comida", 30000],
    ["Coca Cola", "Bebida", 3000],
    ["Jugo Natural", "Bebida", 4500],
    ["Helado", "Postre", 5000],
    ["Torta de Chocolate", "Postre", 7000]
]

# Función para calcular el precio final
def calcular_precio_final(nombre, categoria, precio_base, categoria_objetivo, umbral):
    """
    Aplica 15% de descuento si la categoría coincide y el precio base > umbral.
    Si no, mantiene el precio base.
    """
    if categoria == categoria_objetivo and precio_base > umbral:
        descuento = precio_base * 0.15
        precio_final = precio_base - descuento
    else:
        precio_final = precio_base
    
    return precio_final

# Categoria objetivo y umbral para la promocion 
categoria_objetivo = "Comida"  
umbral = 30000                 

print(f"Promoción: 15% descuento en {categoria_objetivo} con precio > ${umbral}\n")
print(f"{'Producto':<20} {'Categoría':<10} {'Precio Base':<12} {'Precio Final'}")
print("-" * 55)

for producto in menu:
    nombre, categoria, precio_base = producto
    precio_final = calcular_precio_final(nombre, categoria, precio_base, categoria_objetivo, umbral)
    
    print(f"{nombre:<20} {categoria:<10} ${precio_base:<11} ${precio_final:.0f}")

