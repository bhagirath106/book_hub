class ApiResponse<T> {
  const ApiResponse({required this.data, this.total});
  final T data;
  final int? total;
}
