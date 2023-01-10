function C = rescaleMat(A, new_min, new_max)
current_max = max(A(:));
current_min = min(A(:));
C =((A-current_min)*(new_max-new_min))/(current_max-current_min) + new_min;