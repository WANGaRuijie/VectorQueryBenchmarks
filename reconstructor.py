import json
import argparse
import sys
from typing import Any, Dict, List, Union

# --- 配置 ---
# 用来识别向量的最小长度阈值。
# 典型的嵌入向量维度远大于此（如384, 768, 1536）。
DEFAULT_VECTOR_DIM_THRESHOLD = 2 
# 用于在重构后的JSON中命名新ID键的后缀。
# 例如：'embedding' 会变成 'embedding_id'
ID_SUFFIX = '_id' 
# 在最终输出中，存储所有向量的仓库的键名。
VECTOR_STORE_KEY = 'vectors' 
# 在最终输出中，存储重构后原始数据的键名。
RESTRUCTURED_DATA_KEY = 'data' 


class JsonVectorRestructurer:
    """
    一个通用的工具，用于读取JSON数据，检测并提取高维向量，
    并将其重构为一个包含向量仓库和带引用的原始数据的新结构。
    """
    def __init__(self, vector_dim_threshold: int = DEFAULT_VECTOR_DIM_THRESHOLD):
        """
        初始化重构器。

        Args:
            vector_dim_threshold (int): 列表被视为向量的最小长度。
        """
        if vector_dim_threshold <= 0:
            raise ValueError("vector_dim_threshold必须是正整数。")
        self.vector_dim_threshold = vector_dim_threshold
        self.vector_store: Dict[str, List[Union[int, float]]] = {}
        self.id_counter = 0

    def _is_high_dim_vector(self, value: Any) -> bool:
        """
        根据预设规则检测一个值是否为高维向量。
        规则:
        1. 必须是列表 (list)。
        2. 长度必须大于等于设定的阈值。
        3. 所有元素必须是数字 (int 或 float)。
        """
        if not isinstance(value, list) or len(value) < self.vector_dim_threshold:
            return False
        
        # 检查第一个元素是否为数字，这是一个快速的筛选
        if not value or not isinstance(value[0], (int, float)):
            return False
            
        # 完整检查 (如果需要100%精确)
        # 为了性能，可以只检查前几个元素，但完整检查更可靠
        return all(isinstance(item, (int, float)) for item in value)

    def _get_new_vector_id(self) -> str:
        """生成一个唯一的向量ID。"""
        new_id = f"vec_{self.id_counter}"
        self.id_counter += 1
        return new_id

    def _traverse_and_restructure(self, node: Any) -> Any:
        """
        递归遍历JSON节点，查找并替换向量。

        Args:
            node: 当前的JSON节点 (dict, list, 或其他原始类型)。

        Returns:
            重构后的节点。
        """
        if isinstance(node, dict):
            new_dict = {}
            for key, value in node.items():
                if self._is_high_dim_vector(value):
                    # 这是一个向量，提取它
                    vector_id = self._get_new_vector_id()
                    self.vector_store[vector_id] = value
                    
                    # 用带后缀的ID键替换原来的键
                    new_key = f"{key}{ID_SUFFIX}"
                    new_dict[new_key] = vector_id
                else:
                    # 这不是向量，继续向深层遍历
                    new_dict[key] = self._traverse_and_restructure(value)
            return new_dict
        
        elif isinstance(node, list):
            # 递归处理列表中的每一项
            return [self._traverse_and_restructure(item) for item in node]
        
        else:
            # 基本数据类型 (string, int, float, bool, None)，直接返回
            return node

    def restructure_json_data(self, data: Any) -> Dict[str, Any]:
        """
        执行完整的重构过程。

        Args:
            data: 从JSON文件加载的原始数据。

        Returns:
            一个包含向量仓库和重构后数据的字典。
        """
        # 重置状态，以便同一个实例可以多次使用
        self.vector_store = {}
        self.id_counter = 0

        # 开始递归遍历和重构
        restructured_data = self._traverse_and_restructure(data)

        # 组装最终的输出结构
        final_output = {
            RESTRUCTURED_DATA_KEY: restructured_data,
            VECTOR_STORE_KEY: self.vector_store
        }
        
        return final_output


def main():
    """主函数，用于处理命令行参数和文件IO。"""
    parser = argparse.ArgumentParser(
        description="一个通用的JSON文件重构工具，用于提取高维向量。",
        formatter_class=argparse.RawTextHelpFormatter,
        epilog="""
示例用法:
  python restructure_script.py input.json output.json
  python restructure_script.py large_data.json restructured_data.json --threshold 500
"""
    )
    parser.add_argument("input_file", help="输入的JSON文件路径。")
    parser.add_argument("output_file", help="输出的重构后的JSON文件路径。")
    parser.add_argument(
        "-t", "--threshold",
        type=int,
        default=DEFAULT_VECTOR_DIM_THRESHOLD,
        help=f"识别向量的最小维度/长度。 (默认: {DEFAULT_VECTOR_DIM_THRESHOLD})"
    )

    if len(sys.argv) == 1:
        parser.print_help(sys.stderr)
        sys.exit(1)

    args = parser.parse_args()

    try:
        print(f"正在读取文件: {args.input_file}")
        with open(args.input_file, 'r', encoding='utf-8') as f:
            original_data = json.load(f)

        print(f"使用维度阈值 {args.threshold} 进行重构...")
        
        # 创建重构器实例并执行操作
        restructurer = JsonVectorRestructurer(vector_dim_threshold=args.threshold)
        restructured_json = restructurer.restructure_json_data(original_data)
        
        # 统计结果
        num_vectors_found = len(restructured_json[VECTOR_STORE_KEY])
        if num_vectors_found > 0:
            print(f"成功！检测并提取了 {num_vectors_found} 个向量。")
        else:
            print("警告：未在文件中检测到符合条件的高维向量。文件内容将被原样包装。")

        print(f"正在将结果写入文件: {args.output_file}")
        with open(args.output_file, 'w', encoding='utf-8') as f:
            json.dump(restructured_json, f, indent=2, ensure_ascii=False) # 使用 indent=2 使输出更可读

        print("处理完成。")

    except FileNotFoundError:
        print(f"错误: 输入文件未找到 -> '{args.input_file}'", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"错误: 输入文件不是一个有效的JSON格式 -> '{args.input_file}'", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"发生未知错误: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
