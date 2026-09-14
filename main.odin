package main

import "core:fmt"
import "core:math/rand"
import "core:time"

width: int = 30
height: int = 30
cooling: int = 10
spread: int = 1
rand_min: int = -5
rand_max: int = 5

heat: []int
next_heat: []int

init_heat :: proc() {
	heat = make([]int, width * height)
	next_heat = make([]int, width * height)
}

get_index_from_coords :: proc(x: int, y: int) -> int {
	return y * width + x
}

clear_screen :: proc() {
	// Clear the Screen
	// fmt.print("\x1b[2J")
	// Move Cursor Back to the top
	fmt.print("\x1b[H")
}

write :: proc(buffer: []int, x: int, y: int, val: int) {
	index: int = get_index_from_coords(x, y)
	buffer[index] = val
}

display_heat :: proc() {
	for y := 0; y < height; y += 1 {
		for x := 0; x < width; x += 1 {
			num: int = heat[get_index_from_coords(x, y)]
			fmt.printf("%c ", get_display_char(num))
		}
		fmt.println()
	}
}

update_heat :: proc() {
	for x := 0; x < width; x += 1 {
		next_heat[get_index_from_coords(x, height - 1)] = 0
	}

	for x := width / 4; x < width * 3 / 4; x += 1 {
		next_heat[get_index_from_coords(x, height - 1)] = 99
	}

	for y := height - 2; y >= 0; y -= 1 {
		for x := 0; x < width; x += 1 {

			// Pick a cell underneath, but randomly shift left/right.
			offset := rand.int_max(spread * 2 + 1) - spread

			source_x := x + offset

			if source_x < 0 {
				source_x = 0
			}
			if source_x >= width {
				source_x = width - 1
			}

			// Take heat from ONE cell below.
			old_val := heat[get_index_from_coords(source_x, y + 1)]

			// Random cooling.
			decay := rand.int_max(cooling) + 1

			new_val := old_val - decay

			if new_val < 0 {
				new_val = 0
			}

			next_heat[get_index_from_coords(x, y)] = new_val
		}
	}

	temp := heat
	heat = next_heat
	next_heat = temp
}

get_display_char :: proc(num: int) -> rune {
	if num == 0 {
		return ' '
	} else if num >= 1 && num <= 15 {
		return '.'
	} else if num >= 16 && num <= 30 {
		return ':'
	} else if num >= 31 && num <= 45 {
		return '*'
	} else if num >= 46 && num <= 60 {
		return 'o'
	} else if num >= 61 && num <= 75 {
		return 'O'
	} else if num >= 76 && num <= 90 {
		return '#'
	} else {
		return '@'
	}
}

main :: proc() {
	// Initialize Heat Buffer
	init_heat()

	for x := 0; x < width; x += 1 {
		heat[get_index_from_coords(x, height - 1)] = 0
	}

	for x := width / 4; x < width * 3 / 4; x += 1 {
		heat[get_index_from_coords(x, height - 1)] = 99
	}

	// Play the fire animation
	for {
		clear_screen()
		display_heat()
		update_heat()

		time.sleep(40 * time.Millisecond)
	}
}
